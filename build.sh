#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

JW_DOCKER_BUILD_DIR=${1:-}
# drop trailing slash
JW_DOCKER_BUILD_DIR=${JW_DOCKER_BUILD_DIR/%\//}

if [[ -z "$JW_DOCKER_BUILD_DIR" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

LLVM_REL_STR=""
LLVM_REL_VER=""
LLVM_REL_VER_ARG=""
LLVM_REL_STATUS=""
LLVM_REL_STATUS_ARG=""
case "$JW_DOCKER_BUILD_DIR" in
    clang-trunk)
    LLVM_REL_STR=RELEASE
    ;;
    clang-3.9)
    LLVM_REL_STR=RELEASE_39
    ;;
    clang-3.8)
    LLVM_REL_STR=RELEASE_38
    ;;
    clang-3.7)
    LLVM_REL_STR=RELEASE_37
    ;;
    *)
    echo "unknown clang version requested via JW_DOCKER_BUILD_DIR"
esac

if [ -n "$LLVM_REL_STR" ]; then
    LLVM_REL_VER=$(curl --retry 5 -s 'https://llvm.org/svn/llvm-project/llvm/tags/' | sed 's/<[^>]*>//g' | grep "$LLVM_REL_STR" | sed 's/^[[:space:]]*RELEASE_//g' | sed 's/\/$//' | tail -1  | tr -d '[[:space:]]')
    printf "using LLVM_REL_VER=%s\n" "$LLVM_REL_VER"
    LLVM_REL_VER_ARG=--build-arg=LLVM_REL_VER=$LLVM_REL_VER
    printf "using LLVM_REL_VER_ARG=%s\n" "$LLVM_REL_VER_ARG"

    LLVM_REL_STATUS=$(curl --retry 5 -s "https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_$LLVM_REL_VER/" | sed 's/<[^>]*>//g' | grep "rc\|final" | head -1 | sed 's/[[:blank:]]\|\///g' | tr -d '[[:space:]]')
    printf "using LLVM_REL_STATUS=%s\n" "$LLVM_REL_STATUS"
    LLVM_REL_STATUS_ARG=--build-arg=LLVM_REL_STATUS=$LLVM_REL_STATUS
    printf "using LLVM_REL_STATUS_ARG=%s\n" "$LLVM_REL_STATUS_ARG"
fi
docker build \
             $LLVM_REL_VER_ARG \
             $LLVM_REL_STATUS_ARG \
             --build-arg="JW_DOCKER_BUILD_DIR=$JW_DOCKER_BUILD_DIR" \
             -t "jackwasey/$JW_DOCKER_BUILD_DIR" \
             -f "$JW_DOCKER_BUILD_DIR/Dockerfile" \
             .
