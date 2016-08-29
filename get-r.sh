#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#########################################
# Download a version of R in 3.x series #
#########################################

VER=${1:-svn}

echo "Version $VER of R requested for download"

if [ -d "R-devel" ]; then
    echo "R-devel directory already exists"
    exit 1
fi

# example URL: https://cloud.r-project.org/src/base/R-3/R-3.0.0.tar.gz
URL_BASE="https://cloud.r-project.org/src/base/R-3/"

if [[ "$VER" = "svn" ]]; then
    ## Check out R-devel, but it doesn't always compile, whereas the tar balls probably do
    svn co https://svn.r-project.org/R/trunk R-devel
elif [[ "$VER" = "rel" ]]; then
    URL="https://cran.rstudio.com/src/base/R-latest.tar.gz"
elif [[ "$VER" = "pre" ]]; then
    URL="https://cran.rstudio.com/src/base-prerelease/R-latest.tar.gz"
elif [[ $VER =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    URL="${URL_BASE}/R-${VER}.tar.gz"
else
    echo "Version ${VER} not recognized"
    exit 1
fi
curl "$URL" | tar xz
mv R-* R-devel

