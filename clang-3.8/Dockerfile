# don't acutally need r-devel for R, just all the dependencies.
FROM llvm-3.8

## LLVM already built in /usr/local/src


# env should be inherited from llvm docker image
# ENV LLVM_REL=RELEASE_380/rc2

WORKDIR /usr/local/src

# building on LLVM, so just get clang (and do extra stuff in another image)
RUN svn co https://llvm.org/svn/llvm-project/cfe/tags/$LLVM_REL clang
RUN svn co https://llvm.org/svn/llvm-project/compiler-rt/tags/$LLVM_REL compiler-rt
RUN svn co https://llvm.org/svn/llvm-project/clang-tools-extra/tags/$LLVM_REL clang-tools-extra
RUN svn co https://llvm.org/svn/llvm-project/libcxx/tags/$LLVM_REL libcxx
RUN svn co https://llvm.org/svn/llvm-project/libcxxabi/tags/$LLVM_REL libcxxabi
RUN svn co http://llvm.org/svn/llvm-project/openmp/tags/$LLVM_REL openmp

RUN mv clang llvm/tools
RUN mv compiler-rt llvm/projects
RUN mv clang-tools-extra llvm/tools/clang/tools
RUN mv libcxx llvm/projects
RUN mv libcxxabi llvm/projects
RUN mv openmp llvm/projects

# todo remove openmp from this image (it is in llvm)

# TODO: no idea whether libc++ is actually building, being used, whether it should be used when building clang
# see http://libcxx.llvm.org/docs/BuildingLibcxx.html
# http://libcxx.llvm.org/docs/UsingLibcxx.html#alternate-libcxx

RUN cd llvm-build \
  && cmake \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DLLVM_TARGETS_TO_BUILD:STRING=host \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DCLANG_DEFAULT_OPENMP_RUNTIME:STRING=libomp \
  ../llvm 

RUN make -j6 -C llvm-build \
  && make -C llvm-build install \
  && ldconfig

# don't rm yet while debugging
#  && rm -rf llvm-build \

