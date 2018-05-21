#!/usr/bin/env /Library/Frameworks/Mono.framework/Versions/Current/Commands/csharp

using System.Diagnostics;
using System.IO;
using System.Text;

static class Utilities
{
	public static int Verbose = 0;

	public static bool TryRun (string path, string args) => RunCommand (path, args, suppressPrintOnErrors: true) == 0;

	public static string Run (string path, string args)
	{
		StringBuilder output = new StringBuilder ();
		int returnValue = RunCommand (path, args, null, output);
		if (returnValue != 0)
			throw new InvalidOperationException ($"{path} {args} returned {returnValue}");
		return output.ToString ().Replace ("\n", "");;
	}

	public static int RunCommand (string path, string args, string[] env = null, StringBuilder output = null, bool suppressPrintOnErrors = false)
	{
		Exception stdin_exc = null;
		var info = new ProcessStartInfo (path, args);
		info.UseShellExecute = false;
		info.RedirectStandardInput = false;
		info.RedirectStandardOutput = true;
		info.RedirectStandardError = true;
		System.Threading.ManualResetEvent stdout_completed = new System.Threading.ManualResetEvent (false);
		System.Threading.ManualResetEvent stderr_completed = new System.Threading.ManualResetEvent (false);

		if (output == null)
			output = new StringBuilder ();

		if (env != null){
			if (env.Length % 2 != 0)
				throw new Exception ("You passed an environment key without a value");

			for (int i = 0; i < env.Length; i+= 2)
				info.EnvironmentVariables [env[i]] = env[i+1];
		}

		if (Verbose > 0)
			Console.WriteLine ("{0} {1}", path, args);

		using (var p = Process.Start (info)) {

			p.OutputDataReceived += (s, e) => {
				if (e.Data != null) {
					lock (output)
						output.AppendLine (e.Data);
				} else {
					stdout_completed.Set ();
				}
			};

			p.ErrorDataReceived += (s, e) => {
				if (e.Data != null) {
					lock (output)
						output.AppendLine (e.Data);
				} else {
					stderr_completed.Set ();
				}
			};

			p.BeginOutputReadLine ();
			p.BeginErrorReadLine ();

			p.WaitForExit ();

			stderr_completed.WaitOne (TimeSpan.FromSeconds (1));
			stdout_completed.WaitOne (TimeSpan.FromSeconds (1));

			if (p.ExitCode != 0) {
				// note: this repeat the failing command line. However we can't avoid this since we're often
				// running commands in parallel (so the last one printed might not be the one failing)
				if (!suppressPrintOnErrors)
					Console.Error.WriteLine ("Process exited with code {0}, command:\n{1} {2}{3}", p.ExitCode, path, args, output.Length > 0 ? "\n" + output.ToString () : string.Empty);
				return p.ExitCode;
			} else if (Verbose > 0 && output.Length > 0 && !suppressPrintOnErrors) {
				Console.WriteLine (output.ToString ());
			}

			if (stdin_exc != null)
				throw stdin_exc;
		}

		return 0;
	}
}

public class PackageNotFoundException : Exception
{
    public PackageNotFoundException () { }
    public PackageNotFoundException (string message) : base(message) { }
}

static class Blame
{
	static string CreateManifestURL (string branchName, string hash)
	{
		string hashPrefix = hash.Substring (0, 2);
		return $"https://bosstoragemirror.azureedge.net/wrench/macios-mac-{branchName}/{hashPrefix}/{hash}/manifest";
	}

	static IEnumerable<string> BranchesToTry => new List <string> () { "master", "d15-6", "d15-7", "d15-8" };

	static string FindPackageBranch (string hash)
	{
		// This is a hack, but since we don't necessarily have the right branch name
		// mid git blame
		foreach (var branch in BranchesToTry)
		{
			string url = CreateManifestURL (branch, hash);
			string manifestPath = Path.Combine (Path.GetTempPath (), "manifest");
			if (Utilities.TryRun ("wget", $"-nv -O {manifestPath} {url}"))
				return branch;
		}
		return null;
	}

	static string GetPackageUrl (string hash)
	{
		string branchName = FindPackageBranch (hash);
		if (branchName == null)
			throw new PackageNotFoundException ($"Could not find {hash} in [{String.Join (",", BranchesToTry)}].");

		string manifestPath = null;
		try 
		{
			string url = CreateManifestURL (branchName, hash);
			manifestPath = Path.Combine (Path.GetTempPath (), "manifest");
			Utilities.Run ("wget", $"-nv -O {manifestPath} {url}");
			return File.ReadAllLines (manifestPath).First (x => x.Contains (PackageName) && !x.Contains ("toc"));
		}
		finally 
		{
			if (manifestPath != null)
				File.Delete (manifestPath);
		}
	}

	static string GetPackage (string url)
	{
		string localFilePath = Path.Combine (GetBisectCache (), Path.GetFileName (url));
		if (!File.Exists (localFilePath)) {
			Directory.CreateDirectory (GetBisectCache ());
			Utilities.Run ("wget", $"-nv -O {localFilePath} {url}");
		}
		return localFilePath;
	}

	static string GetCurrentHash () => Utilities.Run ("git", "rev-parse HEAD");
	static string GetHome () => Environment.GetEnvironmentVariable ("HOME");
	static string GetBisectCache () => Path.Combine (GetHome (), ".gitbisect/");
	static bool HasEnvVariable (string name) => Environment.GetEnvironmentVariable (name) != null;
	static string PackageName; 

	public static int Main ()
	{
		Utilities.Verbose = HasEnvVariable ("V") ? 1 : 0; 
		PackageName = HasEnvVariable ("XI") ? "xamarin.ios" : "xamarin.mac";
		bool justInstall = HasEnvVariable ("JUST_INSTALL");

		string command = Environment.GetEnvironmentVariable ("COMMAND");
		if (!justInstall && command == null)
			throw new InvalidOperationException ("COMMAND environmental variable required");

		try
		{
			string packageUrl = GetPackageUrl (GetCurrentHash ());
			string localPackage = GetPackage (packageUrl);
			Console.WriteLine ($"Installing {localPackage}"); 
			Utilities.Run ("sudo", $"installer -pkg {localPackage} -target /");
			if (justInstall)
				return 0;

			string [] commandParts = command.Split (' ');  
			string commandRoot = commandParts [0];
			string commandArgs = String.Join (" ", commandParts.Skip (1));
			return Utilities.RunCommand (commandRoot, commandArgs, suppressPrintOnErrors: true);

		}
		catch (PackageNotFoundException)
		{
			return 125; // Skip
		}
	}
}


Environment.Exit (Blame.Main ());
