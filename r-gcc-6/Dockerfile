FROM rocker/r-devel:latest

RUN apt-get update -qq \
    && apt-get install -t unstable -y --no-install-recommends \
		automake \
	        cmake \
                curl \
	        fonts-inconsolata \
	        git \
	        libcurl4-openssl-dev \
	        libssh2-1-dev \
	        libssl-dev \
	        libxml2-dev \
	        pandoc \
	        pandoc-citeproc \
	        qpdf \
	        texlive-base \
     && apt-get clean

RUN awk '$1 ~ "^deb" { $3 = "experimental"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/experimental.list

RUN apt-get update && apt-get install -y -t experimental gcc gfortran && apt-get clean

WORKDIR /usr/local/src

# or subversion?
RUN curl https://cran.rstudio.com/src/base-prerelease/R-latest.tar.gz | tar xz 
RUN mv R-* R-devel

ADD config.site R-devel

# no config.site, default is to use gcc/g++ from Makeconf?
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
	&& ./configure \
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

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site

# clang? R doesn't actually run at all without this (can be considered a test of whether the sanitizers were actually compiled in correctly!)
# clang? ENV ASAN_OPTIONS 'detect_leaks=0:detect_odr_violation=0'

# RUN mkdir ~/.R
# RUN echo "CXX=g++ \n\
# CC=gcc \n\
# CFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable \n\
# CXXFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" > /root/.R/Makevars
# alternatively use `R RHOME`/etc/Makevars.site
