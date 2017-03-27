
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash  ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
  . `brew --prefix`/etc/bash_completion.d/git-prompt.sh
fi

function tabname {
	      printf "\e]1;$1\a"
}
 
function winname {
	      printf "\e]2;$1\a"
}

alias gistcdiff='gist -pcs -t diff'
alias gistc='gist -pcs'
alias v='mvim --remote-tab-silent'
alias vim='mvim --remote-tab-silent'
alias g='rg -g=*.cs'
alias lockscreen='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'
alias gg='git grep'
alias gst='git status --ignore-submodule'
alias ga='git add -p `git status --ignore-submodule --porcelain | cut -c4-`'

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad
export PATH=$PATH:~/bin/
export PS1='\[\e[34m\]\u\[\e[m\]:\[\e[31m\]\w\[\e[m\]$(__git_ps1 " (%s)") $ ' 

d9 ()  {      diff -u /fx/*/Headers/$1 /9x/*/Headers/$1; }

g9 ()  {      grep -s --color $1 /9x/*/Headers/*; }

v9 ()  {      vim /9x/*/Headers/$1; }

vg ()  { vim `grep -s -l $1 /9x/*/Headers/*`; }

fxcd () { cd "$(sharpie xcode -sdkpath "$1")"; }

macbind () { sharpie bind -s macosx10.11 -o ~/Bindings/${1}/${2} -scope . /11x/${1}.framework/Headers/${2}.h; }

iosbind () { sharpie bind -s iPhoneOS -o ~/Bindings/${1}/${2} -scope . /9x/${1}.framework/Headers/${2}.h; }

d11 ()  {      diff -u /fx/*/Headers/$1 /11x/*/Headers/$1; }

g11 ()  {      grep -s --color $1 /11x/*/Headers/*; }

v11 ()  {      vim /11x/*/Headers/$1; }

vg ()  { vim `grep -s -l $1 /11x/*/Headers/*`; }
