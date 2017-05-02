#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# show what we're doing
# set -x

LLVM_REL_VER=${1:-400}

# get release status, e.g. "rc2" or "final"
curl --retry 5 -s "https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_$LLVM_REL_VER/" |
  sed 's/<[^>]*>//g' |
  grep "rc\|final" |
  head -1 |
  sed 's/[[:blank:]]\|\///g' |
  tr -d '[[:space:]]'
