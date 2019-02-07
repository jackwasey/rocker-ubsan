FROM rocker/r-devel:latest

# adapted from https://github.com/docker-library/gcc

RUN set -ex; \
		apt-get update; \
		apt-get -y -qq dist-upgrade; \
		apt-get install -t unstable -y --no-install-recommends \
			automake \
			cmake \
			curl \
			dirmngr \
			fonts-inconsolata \
			git \
			gnupg2 \
			libcurl4-openssl-dev \
			libssh2-1-dev \
			libssl-dev \
			libxml2-dev \
			pandoc \
			pandoc-citeproc \
			qpdf \
			texlive-base \
		; \
		apt-get clean; \
		rm -rf /var/lib/apt/lists/*

# https://gcc.gnu.org/mirrors.html
ENV GPG_KEYS \
# 1024D/745C015A 1999-11-09 Gerald Pfeifer <gerald@pfeifer.com>
	B215C1633BCA0477615F1B35A5B3A004745C015A \
# 1024D/B75C61B8 2003-04-10 Mark Mitchell <mark@codesourcery.com>
	B3C42148A44E6983B3E4CC0793FA9B1AB75C61B8 \
# 1024D/902C9419 2004-12-06 Gabriel Dos Reis <gdr@acm.org>
	90AA470469D3965A87A5DCB494D03953902C9419 \
# 1024D/F71EDF1C 2000-02-13 Joseph Samuel Myers <jsm@polyomino.org.uk>
	80F98B2E0DAB6C8281BDF541A7C8C3B2F71EDF1C \
# 2048R/FC26A641 2005-09-13 Richard Guenther <richard.guenther@gmail.com>
	7F74F97C103468EE5D750B583AB00996FC26A641 \
# 1024D/C3C45C06 2004-04-21 Jakub Jelinek <jakub@redhat.com>
	33C235A34C46AA3FFB293709A328C3A2C3C45C06
RUN set -ex; \
	for key in $GPG_KEYS; do \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	done

# Last Modified: 2017-08-14
ENV GCC_VERSION 7.3.0
# Docker EOL: 2018-08-14

RUN set -ex; \
	\
	buildDeps=' \
		dpkg-dev \
		flex \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $buildDeps; \
	rm -r /var/lib/apt/lists/*; \
	\
	curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz" -o gcc.tar.xz; \
	curl -fSL "http://ftpmirror.gnu.org/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.xz.sig" -o gcc.tar.xz.sig; \
	gpg --batch --verify gcc.tar.xz.sig gcc.tar.xz; \
	mkdir -p /usr/src/gcc; \
	tar -xf gcc.tar.xz -C /usr/src/gcc --strip-components=1; \
	rm gcc.tar.xz*; \
	\
	cd /usr/src/gcc; \
	\
# "download_prerequisites" pulls down a bunch of tarballs and extracts them,
# but then leaves the tarballs themselves lying around
	./contrib/download_prerequisites; \
	{ rm *.tar.* || true; }; \
	\
# explicitly update autoconf config.guess and config.sub so they support more arches/libcs
	for f in config.guess config.sub; do \
		wget -O "$f" "https://git.savannah.gnu.org/cgit/config.git/plain/$f?id=7d3d27baf8107b630586c962c057e22149653deb"; \
# find any more (shallow) copies of the file we grabbed and update them too
		find -mindepth 2 -name "$f" -exec cp -v "$f" '{}' ';'; \
	done; \
	\
	dir="$(mktemp -d)"; \
	cd "$dir"; \
	\
	extraConfigureArgs=''; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "$dpkgArch" in \
# with-arch: https://anonscm.debian.org/viewvc/gcccvs/branches/sid/gcc-6/debian/rules2?revision=9450&view=markup#l491
# with-float: https://anonscm.debian.org/viewvc/gcccvs/branches/sid/gcc-6/debian/rules.defs?revision=9487&view=markup#l416
# with-mode: https://anonscm.debian.org/viewvc/gcccvs/branches/sid/gcc-6/debian/rules.defs?revision=9487&view=markup#l376
		armel) \
			extraConfigureArgs="$extraConfigureArgs --with-arch=armv4t --with-float=soft" \
# TODO get enough builders to test and verify arm32v5 O:)
			;; \
		armhf) \
			extraConfigureArgs="$extraConfigureArgs --with-arch=armv7-a --with-float=hard --with-fpu=vfpv3-d16 --with-mode=thumb" \
# TODO make[2]: *** No rule to make target '/usr/src/gcc/gcc/sync-builtinsndef', needed by 'tree-ssa-loop-prefetch.o'.  Stop.
# (which the builds takes _forever_ to get to)
			;; \
		\
# with-arch-32: https://anonscm.debian.org/viewvc/gcccvs/branches/sid/gcc-6/debian/rules2?revision=9450&view=markup#l590
		i386) \
			osVersionID="$(set -e; . /etc/os-release; echo "$VERSION_ID")"; \
			case "$osVersionID" in \
				8) extraConfigureArgs="$extraConfigureArgs --with-arch-32=i586" ;; \
				*) extraConfigureArgs="$extraConfigureArgs --with-arch-32=i686" ;; \
			esac; \
# TODO for some reason, libgo + i386 fails on https://github.com/gcc-mirror/gcc/blob/gcc-7_1_0-release/libgo/runtime/proc.c#L154
# "error unknown case for SETCONTEXT_CLOBBERS_TLS"
			;; \
	esac; \
	\
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	/usr/src/gcc/configure \
		--build="$gnuArch" \
		--disable-multilib \
		--enable-languages=c,c++,fortran \
		$extraConfigureArgs \
	; \
	make -j "$(nproc)"; \
	make install-strip; \
	\
	cd ..; \
	\
	rm -rf "$dir"; \
	\
	apt-get purge -y --auto-remove $buildDeps

# gcc installs .so files in /usr/local/lib64...
RUN set -ex; \
	echo '/usr/local/lib64' > /etc/ld.so.conf.d/local-lib64.conf; \
	ldconfig -v

# ensure that alternatives are pointing to the new compiler and that old one is no longer used
RUN set -ex; \
	dpkg-divert --divert /usr/bin/gcc.orig --rename /usr/bin/gcc; \
	dpkg-divert --divert /usr/bin/g++.orig --rename /usr/bin/g++; \
	dpkg-divert --divert /usr/bin/gfortran.orig --rename /usr/bin/gfortran; \
	update-alternatives --install /usr/bin/cc cc /usr/local/bin/gcc 999

# RUN awk '$1 ~ "^deb" { $3 = "experimental"; print; exit }' /etc/apt/sources.list > /etc/apt/sources.list.d/experimental.list

# RUN apt-get update && apt-get install -y -t experimental gcc gfortran && apt-get clean

WORKDIR /usr/local/src

# for COPY to work (without duplicating across a bunch of folders) the build context should be the parent directory
COPY bin/get-r.sh .
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
	CXX="g++ -fsanitize=address,undefined,bounds-strict -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
	CXX11="g++ -fsanitize=address,undefined,bounds-strict -fno-sanitize=object-size,vptr -fno-omit-frame-pointer" \
	CFLAGS="-pipe -g -O2 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable -no-pie" \
	CXXFLAGS="-pipe -g -O2 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable -no-pie" \
	FC="gfortran" \
	F77="gfortran" \
	FFLAGS="-pipe -O2 -march=native" \
	FCFLAGS="-pipe -O2 -march=native" \
	./configure \
         --enable-R-shlib \
         --without-blas \
         --without-lapack \
         --with-readline \
         --without-recommended-packages \
         --program-suffix=devsan \
         --disable-openmp \
	&& ASAN_OPTIONS=detect_leaks=0 make -j"$(nproc)" \
	&& ASAN_OPTIONS=detect_leaks=0 make install \
	&& ASAN_OPTIONS=detect_leaks=0 make clean \
	&& rm -rf /usr/local/src/R-devel

ENV ASAN_OPTIONS 'alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0'

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/lib/R/etc/Rprofile.site

# RUN mkdir ~/.R
# RUN echo "CXX=g++ \n\
# CC=gcc \n\
# CFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable \n\
# CXXFLAGS+=-O0 -Wall -Wextra -pedantic -Wno-unused-parameter -Wno-unused-variable" > /root/.R/Makevars
# alternatively use `R RHOME`/etc/Makevars.site

RUN cd /usr/local/bin \
        && mv R Rdevel \
        && mv Rscript Rscriptdevel \
        && mv RD RDold \
        && mv RDscript RDscriptold \
        && ln -s Rdevel RD \
        && ln -s Rscriptdevel RDscript

