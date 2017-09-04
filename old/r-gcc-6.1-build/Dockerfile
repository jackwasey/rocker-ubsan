FROM rocker/r-devel:latest

RUN apt-get update -qq; exit 0
RUN apt-get install -t unstable -y --no-install-recommends \
			automake \
			cmake \
			curl \
			dirmngr \
			fonts-inconsolata \
			git \
			gnupg \
			libcurl4-openssl-dev \
			libssh2-1-dev \
			libssl-dev \
			libxml2-dev \
			pandoc \
			pandoc-citeproc \
			qpdf \
			texlive-base \
		&& apt-get clean

ENV GPG_KEYS \
	B215C1633BCA0477615F1B35A5B3A004745C015A \
	B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
	90AA470469D3965A87A5DCB494D03953902C9419 \
	80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
	7F74F97C103468EE5D750B583AB00996FC26A641 \
	33C235A34C46AA3FFB293709A328C3A2C3C45C06
RUN set -xe \
	&& for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

# Last Modified: 2016-04-27
ENV GCC_VERSION 6.1.0
# Docker EOL: 2017-04-27

# "download_prerequisites" pulls down a bunch of tarballs and extracts them,
# but then leaves the tarballs themselves lying around
RUN buildDeps='flex' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -r /var/lib/apt/lists/* \
	&& curl -fSL --retry 5 "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2" -o gcc.tar.bz2 \
	&& curl -fSL --retry 5 "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.bz2.sig" -o gcc.tar.bz2.sig \
	&& gpg --batch --verify gcc.tar.bz2.sig gcc.tar.bz2 \
	&& mkdir -p /usr/src/gcc \
	&& tar -xf gcc.tar.bz2 -C /usr/src/gcc --strip-components=1 \
	&& rm gcc.tar.bz2* \
	&& cd /usr/src/gcc \
	&& ./contrib/download_prerequisites \
	&& { rm *.tar.* || true; } \
	&& dir="$(mktemp -d)" \
	&& cd "$dir" \
	&& /usr/src/gcc/configure \
		--disable-multilib \
		--enable-languages=c,c++,fortran \
	&& make -j"$(nproc)"
RUN cd /tmp/tmp* && make install-strip \
	&& cd .. \
	&& rm -rf "$dir"

# TODO: put this with previous stanza. don't know why it fails without update first
RUN apt-get update && apt-get purge -y --auto-remove $buildDeps

# gcc installs .so files in /usr/local/lib64...
RUN echo '/usr/local/lib64' > /etc/ld.so.conf.d/local-lib64.conf \
	&& ldconfig -v

# ensure that alternatives are pointing to the new compiler and that old one is no longer used
RUN set -x \
	&& dpkg-divert --divert /usr/bin/gcc.orig --rename /usr/bin/gcc \
	&& dpkg-divert --divert /usr/bin/g++.orig --rename /usr/bin/g++ \
	&& update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999

# RUN awk '$1 ~ "^deb" { $3 = "experimental"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/experimental.list

# RUN apt-get update && apt-get install -y -t experimental gcc gfortran && apt-get clean

WORKDIR /usr/local/src

# for COPY to work (without duplicating across a bunch of folders) the build context should be the parent directory
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
	CC="gcc -std=gnu99 -fsanitize=address,undefined -fno-omit-frame-pointer" \
	CXX="g++ -std=c++14 -fsanitize=address,undefined -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
	CXX1X="g++ -std=c++14 -fsanitize=address,undefined -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
	CFLAGS="-g -O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" \
	CXXFLAGS="-g -O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" \
	FC="gfortran" \
	F77="gfortran" \
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
