FROM rocker/r-devel:latest

## This handle reaches Carl and Dirk
MAINTAINER "Carl Boettiger and Dirk Eddelbuettel" rocker-maintainers@eddelbuettel.com

# RUN echo "deb http://ftp.debian.org/debian experimental main" > /etc/apt/sources.list.d/debian-experimental.list

## Remain current
# can't use debian clang because their build doesn't work with sanitizers
# but can use clang to build clang
RUN apt-get update -qq \
	&& apt-get dist-upgrade -y \
	&& apt-get install -t unstable -y \
		automake \
	        clang-3.7 \
	        cmake \
	        fonts-inconsolata \
	        git \
	        libcurl4-openssl-dev \
	        libssh2-1-dev \
	        libssl-dev \
	        libxml2-dev \
	        pandoc \
	        pandoc-citeproc \
	        qpdf \
	        texlive-base 

## Check out R-devel
RUN cd /tmp \
	&& svn co http://svn.r-project.org/R/trunk R-devel 

# perhaps prefer a branch here, not always head. Original is actually SVN.
RUN cd /tmp
RUN svn co https://llvm.org/svn/llvm-project/llvm/tags/RELEASE_370/final llvm
RUN svn co https://llvm.org/svn/llvm-project/cfe/tags/RELEASE_370/final clang
RUN svn co https://llvm.org/svn/llvm-project/clang-tools-extra/tags/RELEASE_370/final clang-tools-extra
RUN svn co https://llvm.org/svn/llvm-project/compiler-rt/tags/RELEASE_370/final compiler-rt
RUN svn co https://llvm.org/svn/llvm-project/libcxx/tags/RELEASE_370/final libcxx
RUN svn co https://llvm.org/svn/llvm-project/libcxxabi/tags/RELEASE_370/final libcxxabi
RUN svn co http://llvm.org/svn/llvm-project/openmp/tags/RELEASE_370/final openmp

RUN mv clang llvm/tools
RUN mv compiler-rt llvm/projects
RUN mv clang-tools-extra llvm/tools/clang/tools
RUN mv libcxx llvm/projects
RUN mv libcxxabi llvm/projects
RUN mv openmp llvm/projects

RUN mkdir llvm-build
RUN cd llvm-build && \
  cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DLLVM_TARGETS_TO_BUILD:STRING=host \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCLANG_DEFAULT_OPENMP_RUNTIME:STRING=libomp \
  ../llvm

# TODO: consider using clang to build clang
#  -DCMAKE_C_COMPILER=clang-3.7 \
#  -DCMAKE_CXX_COMPILER=clang-3.7 \

# don't use SupC++, we're going to use c++abi from LLVM project.
#  -DLIBCXX_CXX_ABI=libsupc++ \
#  -DLIBCXX_LIBSUPCXX_INCLUDE_PATHS="/usr/include/c++/5/;/usr/include/c++/5/x86_64-linux-gnu/" \
#  -DLLVM_TARGETS_TO_BUILD:STRING=X86 \

# don't use make -j as it may be unfriendly to hosted docker builds.
RUN make -C llvm-build && make -C llvm-build install && rm -rf llvm-build

# eventually clean, but for testing, leave the build tree for diagnosis.
# RUN rm -rf llvm-build

RUN ldconfig

# use config.site to set the R build environment
COPY config.site /tmp/R-devel/config.site
RUN cd /tmp/R-devel \
	&& ./configure \
               --enable-R-shlib \
	       --without-blas \
	       --without-lapack \
	       --with-readline \
	       --without-recommended-packages \
	       --program-suffix=devsan \
     	&& make \
	&& make install \
	&& make clean

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cran.rstudio.com")' >> /usr/local/lib/R/etc/Rprofile.site

# R doesn't actually run at all without this (can be considered a test of whether the sanitizers were actually compiled in correctly!)
ENV ASAN_OPTIONS 'detect_leaks=0:detect_odr_violation=0'

## Check out littler
RUN cd /tmp \
	&& git clone https://github.com/eddelbuettel/littler.git

# R must have been built as a shared library so littler can be built and link to it:
#RUN cd /tmp/littler \
#	&& CC="clang-3.7 -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero,vptr,function -fno-sanitize-recover=undefined,integer" PATH="/usr/local/lib/R/bin/:$PATH" ./bootstrap \
#	&& ./configure --prefix=/usr \
#	&& make \
#	&& make install \
#	&& cp -vax examples/*.r /usr/local/bin 

#RUN cd /usr/local/bin \
#	&& mv R Rdevel \
#	&& mv Rscript Rscriptdevel \
#	&& ln -s Rdevel RD \
#	&& ln -s Rscriptdevel RDscript

RUN Rscript -e "install.packages(c('stringi', 'Rcpp', 'devtools')); library(devtools)"
