#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# show what we're doing
set -x

# Download LLVM with svn, rel or an explicit version number as the argument.

VER=${1:-rel}
URL=""

VER_NUM=$(./get-llvm-ver-num.sh)
VER_NUM_DOTS=$(echo $VER_NUM | sed -e 's/./&\./g')
VER_NUM_DOTS=${VER_NUM_DOTS::-1} # now we should have something like 4.0.0
VER_STR=$(./get-llvm-ver-str.sh "$VER_NUM")

echo "Version '$VER' of LLVM requested for download"
printf "Latest available LLVM release is %s-%s\n" "$VER_NUM" "$VER_STR"

if [ -d "llvm" ]; then
    echo "llvm directory already exists, deleting it"
    rm -rf llvm
fi

if [[ "$VER" = "svn" ]]; then
    ./get-llvm-svn.sh
elif [[ "$VER" = "rel" ]]; then
  if [[ "$VER_STR" = "final" ]]; then
    ./get-llvm-rel.sh "$VER_NUM_DOTS"
  else
    ./get-llvm-svn.sh rel
  fi
elif [[ "$VER" = "svn-rel" ]]; then
    ./get-llvm-svn.sh rel
elif [[ $VER =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  ./get-llvm-rel.sh "$VER"
else
    echo "Version ${VER} not recognized"
    exit 1
fi
