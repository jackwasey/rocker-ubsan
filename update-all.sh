#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# echo expanded commands as we go:
set -x

LIGHTBLUE='\033[34m'
# RED='\033[31m'
NC='\033[0m' # No Color

OUT=$(mktemp /tmp/jw_docker_env_build.log.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

printf "writing to temp dir $LIGHTBLUE%s$NC\n" "$OUT"

echo "Pulling parent docker repos"
docker pull debian:testing >> "$OUT" # we rely on r-devel to be updated?
docker pull rocker/r-devel >> "$OUT"
docker pull debian:stretch >> "$OUT" # for gcc

while read -r dir; do
    if [ ! -d "$dir" ]; then
        echo "$dir not found"
        exit 1
    fi
    dir_trimmed=$(echo "$dir" | sed 's:/*$::')
    printf "Building $LIGHTBLUE%s$NC\n" "$dir_trimmed" | tee -a "$OUT"
    ./build.sh "$dir_trimmed" >> "$OUT"
done < active.txt

# if everything went ok, then delete tmp
rm -rf "$OUT"
