#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

set -x

# Get all the tarballs for an exact release, e.g. 4.0.0

VER=${1:-8.0.0}
LLVM_URL=http://releases.llvm.org

for module in llvm cfe compiler-rt clang-tools-extra libcxx libcxxabi openmp; do
  URL="${LLVM_URL}/${VER}/${module}-${VER}.src.tar.xz"
  curl --retry 5 "$URL" | tar -x -J 
done

# remove version suffices

if ls llvm-* 1>/dev/null 2>&1; then mv llvm-* llvm; fi
if ls cfe-* 1>/dev/null 2>&1; then mv cfe-* clang; fi
mv compiler-rt* compiler-rt
mv libcxx-* libcxx
mv libcxxabi* libcxxabi
mv openmp* openmp
mv clang-tools-extra* clang-tools-extra

mv clang llvm/tools
mv clang-tools-extra llvm/tools/clang/tools
# consider: ln -s llvm/tools/clang llvm/tools/cfe
mv compiler-rt libcxx libcxxabi openmp llvm/projects

