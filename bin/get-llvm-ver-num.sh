#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# show what we're doing
# set -x

LLVM_REL_STR=${1:-40}

# get exact version of latest release in this series, e.g. "401"
curl --retry 5 -s 'https://llvm.org/svn/llvm-project/llvm/tags/' |
sed 's/<[^>]*>//g' |
grep "RELEASE_$LLVM_REL_STR" |
sed 's/^[[:space:]]*RELEASE_//g' |
sed 's/\/$//' |
tail -1  |
tr -d '[[:space:]]'
