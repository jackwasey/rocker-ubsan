FROM jackwasey/r-clang-4.0

COPY bin/install.r .
# this docker image is focussed on testing icd, so install stuff now. use no-byte-compile for build speed
RUN RDscript install.r
