#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# echo everything
# set -x

JW_DOCKER_BUILD_DIR=${1:-}
# drop trailing slash
JW_DOCKER_BUILD_DIR=${JW_DOCKER_BUILD_DIR/%\//}

if [[ -z "$JW_DOCKER_BUILD_DIR" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

docker build \
             -t "jackwasey/$JW_DOCKER_BUILD_DIR" \
             -f "$JW_DOCKER_BUILD_DIR/Dockerfile" \
             .
