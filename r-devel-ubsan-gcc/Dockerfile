# Based heavily on rocker/r-devel-san and friends from Dirk Eddelbuettel.
# Uses the GCC in whichever version of debian this image inherits from r-devel.
# At the moment, this is debian:testing

FROM rocker/r-devel:latest

# use unstable to get the right development library versions
RUN apt-get update -y && apt-get install -y -t unstable \
      curl \
      fonts-inconsolata \
      git \
      libcurl4-openssl-dev \
      libssl-dev/unstable \
      libxml2-dev/unstable \
      libssh2-1-dev \
      pandoc \
      pandoc-citeproc \
      qpdf \
      texlive-base \
      unixodbc-dev \
    && apt-get clean

WORKDIR /usr/local/src

COPY bin/get-r.sh .
RUN ./get-r.sh

# GCC UBSAN and OpenMP don't work together in any version! appears to be no evidence of fix
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64888

ENV ASAN_OPTIONS alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0

# no config.site at present

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
           CFLAGS="-g -Wall -pedantic -O0" \
           CXXFLAGS="-g -Wall -pedantic -O0" \
           CC="gcc -std=gnu99 -fsanitize=address,undefined -fno-omit-frame-pointer" \
           CXX="g++ -fsanitize=address,undefined  -fno-omit-frame-pointer -fno-sanitize=object-size,vptr" \
           CXX1X="g++ -fsanitize=address,undefined  -fno-omit-frame-pointer -fno-sanitize=object-size,vptr" \
           FC="gfortran -fsanitize=address" \
           F77="gfortran -fsanitize=address" \
     FCFLAGS="-g -O0 -mtune=native" \
     FFLAGS="-g -O0 -mtune=native" \
     MAIN_LDFLAGS="-fsanitize=address,undefined" \
        ./configure --enable-R-shlib \
          --without-blas \
          --without-lapack \
          --disable-openmp \
          --with-readline \
          --without-recommended-packages \
          --program-suffix=dev \
        && make -j8 \
        && make install \
        && make clean \
        && cd .. \
        && rm -rf R-devel

# remove or keep -O0 flags? Not sure which would be most helpful. Most code in production use is compiled O2, but I don't know whether O0 would uncover the same UBSAN bugs, or just allow them to be characterized more easily. BDR used -O2 in the memtests he did on this package.

# don't need this, since we don't have a config.site file at present, but required to build docker image
ARG JW_DOCKER_BUILD_DIR=.

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libasan.so.2
CMD ["Rdevel"]
