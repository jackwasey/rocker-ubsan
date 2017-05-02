#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# show what we're doing
# set -x

LLVM_REL=${1:-trunk}
# otherwise, it has to be something like "tags/RELEASE_401/rc1"

if [[ "$LLVM_REL" =~ "rel" ]]; then
  REL_NUM=$(./get-llvm-ver-num.sh)
  REL_STR=$(./get-llvm-ver-str.sh $REL_NUM)
  LLVM_REL="tags/RELEASE_${REL_NUM}/${REL_STR}"
fi

SVN_URL=https://llvm.org/svn/llvm-project

svn co $SVN_URL/llvm/$LLVM_REL llvm
svn co $SVN_URL/cfe/$LLVM_REL clang
svn co $SVN_URL/compiler-rt/$LLVM_REL compiler-rt
svn co $SVN_URL/clang-tools-extra/$LLVM_REL clang-tools-extra
svn co $SVN_URL/libcxx/$LLVM_REL libcxx
svn co $SVN_URL/libcxxabi/$LLVM_REL libcxxabi
svn co $SVN_URL/openmp/$LLVM_REL openmp
mv clang llvm/tools
mv clang-tools-extra llvm/tools/clang/tools
mv compiler-rt libcxx libcxxabi openmp llvm/projects
