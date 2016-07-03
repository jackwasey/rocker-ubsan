#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

if [[ -v JW_R_SVN ]]
then
    curl https://cran.rstudio.com/src/base-prerelease/R-latest.tar.gz | tar xz
    mv R-* R-devel
else
## Check out R-devel, but it doesn't always compile, but the tar balls
    svn co https://svn.r-project.org/R/trunk R-devel
fi

