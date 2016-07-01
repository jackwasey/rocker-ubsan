#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
NC='\033[0m' # No Color

docker pull rocker/r-devel
docker pull debian:stretch

for dir in */ ; do
    #dir_trimmed=${dir%/}
    dir_trimmed=$(echo "$dir" | sed 's:/*$::')
    #printf "building %s%s%s" "$RED" "$dir_trimmed" "$NC"
    printf "building %s\n" "$dir_trimmed"
    ./build.sh "$dir_trimmed"
done
