#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#########################################
# Download a version of R in 3.x series #
#########################################

VER=${1:-svn}
CRAN_URL=https://cloud.r-project.org
SVN_URL=https://svn.r-project.org/R/trunk
URL=""

echo "Version $VER of R requested for download"

if [ -d "R-devel" ]; then
    echo "R-devel directory already exists, deleting it"
    rm -rf R-devel
fi

# example URL: https://cloud.r-project.org/src/base/R-3/R-3.0.0.tar.gz

if [[ "$VER" = "svn" ]]; then
    ## Check out R-devel, but it doesn't always compile, whereas the tar balls probably do
    svn co "$SVN_URL" R-devel
    exit 0
elif [[ "$VER" = "rel" ]]; then
    URL="${CRAN_URL}/src/base/R-latest.tar.gz"
elif [[ "$VER" = "pre" ]]; then
    URL="${CRAN_URL}/src/base-prerelease/R-latest.tar.gz"
elif [[ $VER =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    URL="${CRAN_URL}/src/base/R-3/R-${VER}.tar.gz"
    echo "Getting R source from: $URL"
else
    echo "Version ${VER} not recognized"
    exit 1
fi

curl --retry 5 "$URL" | tar xz
mv R-* R-devel
