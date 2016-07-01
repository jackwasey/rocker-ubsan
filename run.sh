#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dir=${1:-}

if [[ -z "$dir" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

docker run --rm -ti "jackwasey/$dir" $dir bash

