FROM jackwasey/clang-3.9

WORKDIR /usr/local/src

# for COPY to work (without duplicating across a bunch of folders) the build context should be the parent directory
COPY get-r.sh .
RUN ./get-r.sh 3.0.3

ARG JW_DOCKER_BUILD_DIR=.
COPY ${JW_DOCKER_BUILD_DIR}/* ./
RUN mv config.site R-devel/config.site

# R doesn't actually run at all without this (can be considered a test of whether the sanitizers were actually compiled in correctly!)
# may need the following if R itself fails sanitizer: ASAN_OPTIONS=halt_on_error=0
ENV ASAN_OPTIONS 'detect_leaks=0:detect_odr_violation=0'

RUN cd R-devel \
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
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site

