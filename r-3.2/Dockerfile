FROM jackwasey/clang-3.9

WORKDIR /usr/local/src

#RUN apt-get update && apt-get install -y curl

COPY get-r.sh .
RUN ./get-r.sh 3.2.4

ARG JW_DOCKER_BUILD_DIR=.
COPY ${JW_DOCKER_BUILD_DIR}/* ./
RUN mv config.site R-devel/config.site

RUN cd R-devel \
	&& ./configure \
               --enable-R-shlib \
	       --without-blas \
	       --without-lapack \
	       --with-readline \
	       --without-recommended-packages \
     	&& make \
	&& make install \
	&& make clean

## Set Renviron to get libs from base R install
RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron

## Set default CRAN repo
RUN echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site

