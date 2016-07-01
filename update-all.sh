#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

RED='\033[0;31m'
NC='\033[0m' # No Color

docker pull r-devel
docker pull debian:stretch

for dir in */ ; do
    printf "building %s%s%s" "$RED" "$dir" "$NC"
    ./build.sh "$dir"
done
