FROM debian:stretch

RUN apt-get update -qq; exit 0
RUN apt-get install -y --no-install-recommends \
    automake \
    cmake \
    curl \
    fonts-inconsolata \
    gcc-6 \
    g++-6 \
    gdb \
    gfortran-6 \
    git \
    libcurl4-openssl-dev \
    libssh2-1-dev \
    libssl-dev \
    libxml2-dev \
    pandoc \
    pandoc-citeproc \
    qpdf \
    bison \
    debhelper \
    default-jdk \
    groff-base \
    libblas-dev \
    libbz2-dev \
    libcairo2-dev \
    libjpeg-dev \
    liblapack-dev \
    liblzma-dev \
    libncurses5-dev \
    libpango1.0-dev \
    libpcre3-dev \
    libpng-dev \
    libreadline-dev \
    libtiff5-dev \
    libx11-dev \
    libxt-dev \
    mpack \
    subversion \
    tcl8.6-dev \
    texinfo \
    texlive-base \
    texlive-extra-utils \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-latex-recommended \
    tk8.6-dev \
    x11proto-core-dev \
    xauth \
    xdg-utils \
    xfonts-base \
    xvfb \
    zlib1g-dev
#     && apt-get clean

# RUN awk '$1 ~ "^deb" { $3 = "experimental"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/experimental.list
# RUN apt-get update && apt-get install -y -t experimental gcc gfortran && apt-get clean

WORKDIR /usr/local/src

COPY get-r.sh .
RUN ./get-r.sh

ARG JW_DOCKER_BUILD_DIR=.
COPY ${JW_DOCKER_BUILD_DIR}/* ./
RUN mv config.site R-devel/config.site

RUN mkdir -p ~/.R
RUN mv Makevars ~/.R

# must disable openmp to enable ubsan when compiling R itself
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
  CC="gcc-6 -std=gnu99 -fsanitize=address,undefined -fno-omit-frame-pointer" \
  CXX="g++-6 -std=c++14 -fsanitize=address,undefined -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
  CXX1X="g++-6 -std=c++14 -fsanitize=address,undefined -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
  CFLAGS="-g -O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" \
  CXXFLAGS="-g -O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" \
  FC="gfortran-6" \
  F77="gfortran-6" \
  FFLAGS="-g -O2 -march=native" \
  FCFLAGS="-g -O2 -march=native" \
  ./configure \
    --enable-R-shlib \
    --without-blas \
    --without-lapack \
    --with-readline \
    --without-recommended-packages \
    --program-suffix=devsan \
    --disable-openmp \
  && make -j5 \
  && make install \
  && make clean \
        && cd /usr/local/src \
  && rm -rf R-devel

ENV ASAN_OPTIONS 'alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0'

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site

# RUN mkdir ~/.R
# RUN echo "CXX=g++ \n\
# CC=gcc \n\
# CFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable \n\
# CXXFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" > /root/.R/Makevars
# alternatively use `R RHOME`/etc/Makevars.site
