#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dir=${1:-}
dir=${dir/%\//}

if [[ -z "$dir" ]]; then
    echo "usage: $0 NAME"
    exit 1
fi

jwdock="jackwasey/$dir"
echo "Starting docker with $jwdock"
docker run --rm -ti "$jwdock" bash
