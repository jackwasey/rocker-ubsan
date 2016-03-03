# Based heavily on rocker/r-devel-san and friends from Dirk Eddelbuettel. Uses the GCC in whichever version of debian this image inherits from r-devel.

FROM rocker/r-devel:latest

# use unstable to get the right development library versions
RUN apt-get install -y -t unstable \
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
  unixodbc-dev

 RUN cd /tmp \
        && svn co http://svn.r-project.org/R/trunk R-devel

# SVN R-devel doesn't always compile. An alternative is to grab the devel tar:
# https://stat.ethz.ch/R/daily/R-devel.tar.bz2 but this is just a svn snap which may not compile either
#
# the following is a beta version, and appears to be attached to a revision of SVN repo which is not the latest (and thus suggests it is more likely to compile) Temporarily use this instead of SVN
RUN rm -rf /tmp/R-devel \
      && cd /tmp \
      && curl https://cran.rstudio.com/src/base-prerelease/R-latest.tar.gz | tar xz \
      # move beta to devel so i can switch back to svn easily
      && mv /tmp/R-beta /tmp/R-devel




# GCC UBSAN and OpenMP don't work together in any version! appears to be no evidence of fix
# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64888

ENV ASAN_OPTIONS detect_leaks=0:detect_odr_violation=0

# build R-devel again, but with sanitizers
RUN cd /tmp/R-devel \
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
           CFLAGS="-g -Wall -pedantic -O2" \
           CXXFLAGS="-g -Wall -pedantic -O2" \
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
        && make -j5 \
        && make install \
        && make clean

# remove or keep -O0 flags? Not sure which would be most helpful. Most code in production use is compiled O2, but I don't know whether O0 would uncover the same UBSAN bugs, or just allow them to be characterized more easily. BDR used -O2 in the memtests he did on this package.

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libasan.so.2
CMD ["Rdevel"]

