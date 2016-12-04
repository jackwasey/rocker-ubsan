# don't acutally need r-devel for R, just all the dependencies.
FROM rocker/r-devel:latest

RUN apt-get update -qq; exit 0
RUN apt-get install -t unstable -y --no-install-recommends \
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
        texlive-base

# LLVM_REL_VER must be passed in to docker build command
ARG LLVM_REL_VER
ARG LLVM_REL_STATUS
ARG JW_DOCKER_BUILD_DIR=
# this may fail if there is a release candidate but no "final"
# solution may be just to query the parent directory and find last rc version if no final
ENV LLVM_REL=/tags/RELEASE_${LLVM_REL_VER}/${LLVM_REL_STATUS}

WORKDIR /usr/local/src

RUN svn co  https://llvm.org/svn/llvm-project/llvm/$LLVM_REL llvm \
 && svn co  https://llvm.org/svn/llvm-project/cfe/$LLVM_REL clang \
 && svn co  https://llvm.org/svn/llvm-project/compiler-rt/$LLVM_REL compiler-rt \
 && svn co  https://llvm.org/svn/llvm-project/clang-tools-extra/$LLVM_REL clang-tools-extra \
 && svn co  https://llvm.org/svn/llvm-project/libcxx/$LLVM_REL libcxx \
 && svn co  https://llvm.org/svn/llvm-project/libcxxabi/$LLVM_REL libcxxabi \
 && svn co  http://llvm.org/svn/llvm-project/openmp/$LLVM_REL openmp \
 && mv clang llvm/tools \
 && mv clang-tools-extra llvm/tools/clang/tools \
 && mv compiler-rt libcxx libcxxabi openmp llvm/projects

RUN mkdir llvm-build \
  && cd llvm-build \
  && cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DLLVM_TARGETS_TO_BUILD:STRING=host \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCLANG_DEFAULT_OPENMP_RUNTIME:STRING=libomp \
  ../llvm \
    && make -j6 \
    && make install \
    && make clean \
    && cd .. \
    && rm -rf llvm-build \
    && ldconfig
