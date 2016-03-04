# don't acutally need r-devel for R, just all the dependencies.
FROM rocker/r-devel:latest

RUN apt-get update -qq \
	&& apt-get dist-upgrade -y \
	&& apt-get install -t unstable -y --no-install-recommends \
		automake \
	        # clang-3.7 \
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
	        texlive-base 

ENV LLVM_REL=RELEASE_380/rc2

WORKDIR /usr/local/src

# just build LLVM and clang first, extras built in subsequent Dockerfile
RUN svn co https://llvm.org/svn/llvm-project/llvm/tags/$LLVM_REL llvm

# try to add omp at this stage
RUN svn co http://llvm.org/svn/llvm-project/openmp/tags/$LLVM_REL openmp
RUN mv openmp llvm/projects

RUN mkdir llvm-build \
  && cd llvm-build && \
  cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DLLVM_TARGETS_TO_BUILD:STRING=host \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCLANG_DEFAULT_OPENMP_RUNTIME:STRING=libomp \
  ../llvm 

RUN make -C llvm-build \
  && make -j6 -C llvm-build install

#  && ldconfig
# don't rm because we still have to build libcxx and libomp in another image
#  && rm -rf llvm-build \

