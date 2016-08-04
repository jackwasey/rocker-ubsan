#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

export JW_DOCKER_BUILD_DIR=${1:-}

if [[ -z "$JW_DOCKER_BUILD_DIR" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

# for simplicity, always check LLVM release version, even if not compiling LLVM
LLVM_REL_VER=

LLVM_REL_VER_ARG=""
LLVM_REL_STATUS_ARG=""
case "$JW_DOCKER_BUILD_DIR" in
    clang-latest)
    LLVM_REL_VER=$(curl -s 'https://llvm.org/svn/llvm-project/llvm/tags/' | sed 's/<[^>]*>//g' | grep RELEASE | sed 's/^[[:space:]]*RELEASE_//g' | sed 's/\/$//' | tail -1)
    ;;
    clang-3.8)
    LLVM_REL_VER=$(curl -s 'https://llvm.org/svn/llvm-project/llvm/tags/' | sed 's/<[^>]*>//g' | grep RELEASE_38 | sed 's/^[[:space:]]*RELEASE_//g' | sed 's/\/$//' | tail -1)
    ;;
    *)
    echo "unknown clang version requested via JW_DOCKER_BUILD_DIR"
    exit 1
esac 
LLVM_REL_VER_ARG="--build-arg=LLVM_REL_VER=${LLVM_REL_VER}"
printf "using LLVM_REL_VER_ARG = %s\n" "$LLVM_REL_VER_ARG"
LLVM_REL_STATUS=$(curl -s "https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_$LLVM_REL_VER/" | sed 's/<[^>]*>//g' | grep "rc\|final" | head -1 | sed 's/[[:blank:]]\|\///g')
LLVM_REL_STATUS_ARG="--build-arg=LLVM_REL_STATUS=${LLVM_REL_STATUS}"
printf "using LLVM_REL_STATUS_ARG = %s\n" "$LLVM_REL_STATUS_ARG"

docker build "$LLVM_REL_VER_ARG" "$LLVM_REL_STATUS_ARG" --build-arg="JW_DOCKER_BUILD_DIR=$JW_DOCKER_BUILD_DIR" -t "jackwasey/$JW_DOCKER_BUILD_DIR" -f "$JW_DOCKER_BUILD_DIR/Dockerfile" .
