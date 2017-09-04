FROM jackwasey/r-clang-4.0

# this docker image is focussed on testing icd, so install stuff now. use no-byte-compile for build speed

RUN apt-get update; \
      apt-get dist-upgrade -y; \
      apt-get install -y -qq libssl-dev libxml2-dev curl libcurl4-openssl-dev unixodbc-dev qpdf pandoc pandoc-citeproc

RUN Rscript -e \
      'pkgs <- c("knitr", "Rcpp", "testthat", "checkmate", "RODBC", "xml2", "rmarkdown"); \
       for (p in pkgs) { if (!require(p, character.only=T)) install.packages(p) }'

RUN RDscript -e \
      'pkgs <- c("knitr", "Rcpp", "testthat", "checkmate", "RODBC", "xml2", "rmarkdown"); \
       for (p in pkgs) { if (!require(p, character.only=T)) install.packages(p) }'
