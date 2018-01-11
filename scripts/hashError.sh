#!/bin/bash
set -e

Filename=$1
Command="${@:2}"
	
main() {
	set +e
	Output="$($Command 2>&1)"
	set -e
	echo "$Output" | find-errors | find-filename | split-line-error | sort -u
}

find-errors() {
	grep "error"
}

find-filename() {
	grep $Filename 
}

split-line-error() {
	awk -F': error' '{print $2}'
}	

main $@
