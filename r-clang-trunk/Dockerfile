# don't acutally need r-devel for R, just all the dependencies.
FROM jackwasey/clang-trunk

WORKDIR /usr/local/src

## Check out R-devel
# RUN svn co http://svn.r-project.org/R/trunk R-devel 

# SVN R-devel doesn't always compile. An alternative is to grab the devel tar:
# https://stat.ethz.ch/R/daily/R-devel.tar.bz2 but this is just a svn snap which may not compile either
#
# the following is a rc version, and appears to be attached to a revision of SVN repo which is not the latest (and thus suggests it is more likely to compile) Temporarily use this instead of SVN
RUN curl https://cran.rstudio.com/src/base-prerelease/R-latest.tar.gz | tar xz
RUN mv R-* R-devel

# use config.site to set the R build environment
COPY config.site R-devel/config.site
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
RUN echo 'options("repos"="https://cran.rstudio.com")' >> /usr/local/lib/R/etc/Rprofile.site

# R doesn't actually run at all without this (can be considered a test of whether the sanitizers were actually compiled in correctly!)
ENV ASAN_OPTIONS 'detect_leaks=0:detect_odr_violation=0'

