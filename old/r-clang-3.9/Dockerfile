FROM jackwasey/clang-3.9

MAINTAINER "Jack Wasey" jack@jackwasey.com

WORKDIR /usr/local/src

# for COPY to work (without duplicating across a bunch of folders) the build context should be the parent directory
COPY bin/get-r.sh .
# accepts svn, rel and pre
RUN ./get-r.sh rel

ARG JW_DOCKER_BUILD_DIR=.
COPY ${JW_DOCKER_BUILD_DIR}/* ./

# put it all in this Dockerfile. each clang/gcc/R combo is different, so code re-use just causing problems
#RUN mv config.site R-devel/config.site

# must be used with --cap-add SYS_PTRACE so LSAN can attach to its monitor thread
# https://github.com/google/sanitizers/issues/764
# but this is unavailable for docker build...


# for CXX try -nostdinc -nostdlibinc to stop it puling in gcc crap every time.
# -nodefaultlibs dropped - it can't seem to find pthread things even if I specify -lgcc etc etc (-lc++ -lc++abi -lm -lc -lgcc_s -lgcc )
# r-clang-trunk did not have -stdlib=libc++ or no-omit-frame-pointer, or the c++ path

# need LDFLAGS because we built clang ourselves. may or may not want c++abi
#LDFLAGS="-L/usr/local/lib/clang/4.0.0/lib/linux -L/usr/local/lib -lc++abi"

# R figures out whether we need -std=c++11 itself, so don't need to add flag here (and it can be harmful?)
#CXX1X="${CXX}"
#CXX11="${CXX}"
#CXX14="${CXX}"

# CFLAGS may need "-std=gnu99" (was in r-clang-trunk build

# OPENMP_CFLAGS instead of R_OPENMP_CFLAGS? THis is for building R specifically, not for using openmp in packages, I believe.
#R_OPENMP_CFLAGS=-fopenmp
#R_LD_LIBRARY_PATH=/usr/local/lib

RUN cd R-devel \
        && R_PAPERSIZE=letter \
           R_BATCHSAVE="--no-save --no-restore" \
           R_BROWSER=xdg-open \
           PAGER=/usr/bin/pager \
           PERL=/usr/bin/perl \
           R_UNZIPCMD=/usr/bin/unzip \
           R_ZIPCMD=/usr/bin/zip \
           R_PRINTCMD=/usr/bin/lpr \
           LIBnn=lib \
           AWK=/usr/bin/awk \
           CC="clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-omit-frame-pointer" \
           CXX="clang++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -stdlib=libc++ -fno-omit-frame-pointer -I/usr/local/include/c++/v1 -I/usr/local/include" \
           FFLAGS="-g -O2 -mtune=native" \
           FCFLAGS="-g -O2 -mtune=native" \
           CFLAGS="-pipe -Wall -Wextra -pedantic -Wno-unused-parameter -g -O0 -mtune=native" \
           CXXFLAGS="-pipe -Wall -Wextra -pedantic -Wno-unused-parameter -g -O0 -mtune=native" \
           MAIN_LD="clang++ -stdlib=libc++ -fsanitize=undefined,address" \
           LDFLAGS="-L/usr/local/lib/clang/3.9.1/lib/linux -L/usr/local/lib -lc++abi" \
           ./configure --enable-R-shlib \
              --without-blas \
              --without-lapack \
              --with-readline \
              --without-recommended-packages \
              --program-suffix=dev \
              #--disable-openmp \
        && make -j4 \
        && make install \
        && make clean

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site

# R doesn't actually run at all without this (can be considered a test of whether the sanitizers were actually compiled in correctly!)
# but rocker/r-devel-ubsan-clang does work without this
# see: http://www.stats.ox.ac.uk/pub/bdr/memtests/README.txt

ENV ASAN_OPTIONS 'alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0'

## Create R-devel symlinks
RUN cd /usr/local/bin \
        && mv R Rdevelnew \
        && mv Rscript Rscriptdevelnew \
        && mv RD RDold \
        && mv RDscript RDscriptold \
        && ln -s Rdevelnew RD \
        && ln -s Rscriptdevelnew RDscript

# this docker image is focussed on testing icd, so install stuff now. use no-byte-compile for build speed
RUN RDscript -e "install.packages(c('codetools', 'testthat', 'Rcpp', 'RColorBrewer', 'dichromat', 'munsell', 'checkmate', 'scales', 'proto', 'caTools', 'evaluate', 'knitr', 'xtable', 'rmarkdown', 'fastmatch', 'RODBC', 'roxygen2', 'xml2'), INSTALL_opts = '--no-byte-compile')"
