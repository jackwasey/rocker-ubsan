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

ENV LLVM_REL=trunk

WORKDIR /usr/local/src

# just build LLVM and clang first, extras built in subsequent Dockerfile
RUN svn co https://llvm.org/svn/llvm-project/llvm/$LLVM_REL llvm

# try to add omp at this stage
RUN svn co https://llvm.org/svn/llvm-project/cfe/$LLVM_REL clang
RUN svn co https://llvm.org/svn/llvm-project/compiler-rt/$LLVM_REL compiler-rt
RUN svn co https://llvm.org/svn/llvm-project/clang-tools-extra/$LLVM_REL clang-tools-extra
RUN svn co https://llvm.org/svn/llvm-project/libcxx/$LLVM_REL libcxx
RUN svn co https://llvm.org/svn/llvm-project/libcxxabi/$LLVM_REL libcxxabi
RUN svn co http://llvm.org/svn/llvm-project/openmp/$LLVM_REL openmp

RUN mv clang llvm/tools
RUN mv compiler-rt llvm/projects
RUN mv clang-tools-extra llvm/tools/clang/tools
RUN mv libcxx llvm/projects
RUN mv libcxxabi llvm/projects
RUN mv openmp llvm/projects

RUN mkdir llvm-build \
  && cd llvm-build && \
  cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DLLVM_TARGETS_TO_BUILD:STRING=host \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCLANG_DEFAULT_OPENMP_RUNTIME:STRING=libomp \
  ../llvm 

RUN make -C llvm-build && make -j6 -C llvm-build install && ldconfig

#  && ldconfig
# don't rm because we still have to build libcxx and libomp in another image
#  && rm -rf llvm-build \

