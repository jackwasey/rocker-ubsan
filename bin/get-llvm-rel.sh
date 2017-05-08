#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# show what we're doing
# set -x

# Get all the tarballs for an exact release, e.g. 4.0.0

VER=${1:-4.0.0}
LLVM_URL=http://releases.llvm.org

for module in llvm cfe compiler-rt clang-tools-extra libcxx libcxxabi openmp; do
  URL="${LLVM_URL}/${VER}/llvm-${VER}.src.tar.xz"
  curl --retry 5 "$URL" | tar xJ
done

mv clang llvm/tools
mv clang-tools-extra llvm/tools/clang/tools
mv compiler-rt libcxx libcxxabi openmp llvm/projects
