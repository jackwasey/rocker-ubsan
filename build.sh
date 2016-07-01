#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dir=${1:-}

if [[ -z "$dir" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi


docker build -t "jackwasey/$dir" $dir
