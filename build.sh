#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

export JW_DOCKER_BUILD_DIR=${1:-}

if [[ -z "$JW_DOCKER_BUILD_DIR" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

# for simplicity, always check LLVM release version, even if not compiling LLVM
LLVM_REL_VER=$(curl -s 'https://llvm.org/svn/llvm-project/llvm/tags/' | sed 's/<[^>]*>//g' | grep RELEASE | sed 's/^[[:space:]]*RELEASE_//g' | sed 's/\/$//' | tail -1)

LLVM_REL_ARG=""
if [ "$JW_DOCKER_BUILD_DIR" = "clang-3.8" ]; then
    LLVM_REL_ARG="--build-arg=LLVM_REL_VER=${LLVM_REL_VER}"
    printf "using LLVM_REL_ARG = %s\n" "$LLVM_REL_ARG"
fi

docker build $LLVM_REL_ARG --build-arg=JW_DOCKER_BUILD_DIR=$JW_DOCKER_BUILD_DIR -t "jackwasey/$JW_DOCKER_BUILD_DIR" -f "$JW_DOCKER_BUILD_DIR/Dockerfile" .
