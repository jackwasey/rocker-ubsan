#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

LIGHTBLUE='\033[34m'
RED='\033[31m'
NC='\033[0m' # No Color

OUT=$(mktemp /tmp/jw_docker_env_build.XXXXXXXXXX.log) || { echo "Failed to create temp file"; exit 1; }

printf "writing to temp dir $LIGHTBLUE%s$NC\n" "$OUT"

docker pull rocker/r-devel >> $OUT
docker pull debian:stretch >> $OUT

for dir in */ ; do
    #dir_trimmed=${dir%/}
    dir_trimmed=$(echo "$dir" | sed 's:/*$::')
    printf "Building $LIGHTBLUE%s$NC\n" "$dir_trimmed" | tee -a $OUT
    #printf "building %s\n" "$dir_trimmed" >> $OUT
    ./build.sh "$dir_trimmed" >> $OUT
done

# if everything went ok, then delete tmp
rm -rf "$OUT"

