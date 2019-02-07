Tests of memory access errors, on x86_64 Linux (currently Fedora 26).

There is a directory for each package with a 00check.log file documenting the
package version and the version of R used.  For {gcc,clang}-ASAN this may
also report errors, including from examples.

How to run and interpret these (with links to further information) is in §4.3 of 'Writing R Extensions'.  The settings used are listed by sub-directory in the rest of this file.

clang-ASAN, clang-UBSAN:
Using clang built with libc++/libcxxabi as the default C++ library.
config.site:
CC="clang -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-omit-frame-pointer"
CXX="clang++ -stdlib=libc++ -fsanitize=address,undefined -fno-sanitize=float-divide-by-zero -fno-omit-frame-pointer -frtti"
CFLAGS="-g -O3 -Wall -pedantic"
FFLAGS="-g -O2 -mtune=native"
FCFLAGS="-g -O2 -mtune=native" 
CXXFLAGS="-g -O3 -Wall -pedantic"
MAIN_LD="clang++ -fsanitize=undefined,address"

and environment variable
setenv ASAN_OPTIONS 'alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0'
(mismatches were seen in system libraries used by rgl)

Done with clang 5.0.0.


gcc-ASAN, gcc-UBSAN:
gcc 7.1 with config.site:
CFLAGS="-g -O2 -Wall -pedantic -mtune=native -fsanitize=address"
FFLAGS="-g -O2 -mtune=native"
FCFLAGS="-g -O2 -mtune=native"
CXXFLAGS="-g -O2 -Wall -pedantic -mtune=native"
MAIN_LDFLAGS=-fsanitize=address,undefined

~/.R/Makevars:
CC = gcc -std=gnu99 -fsanitize=address,undefined -fno-omit-frame-pointer
CXX = g++ -fsanitize=address,undefined,bounds-strict -fno-omit-frame-pointer -fno-sanitize=object-size,vptr
CXX1X = g++ -fsanitize=address,undefined,bounds-strict -fno-omit-frame-pointer -fno-sanitize=object-size,vptr
F77 = gfortran -fsanitize=address
FC = gfortran -fsanitize=address
FCFLAGS = -g -O2 -mtune=native -fbounds-check
FFLAGS = -g -O2 -mtune=native -fbounds-check

and environment variable
setenv ASAN_OPTIONS 'alloc_dealloc_mismatch=0:detect_leaks=0:detect_odr_violation=0'


valgrind:
Running R CMD check --use-valgrind with an instrumented (level 2) build
of R using gcc 6.3 on Fedora 24.

configured by:
.../configure -C --with-valgrind-instrumentation=2 --with-system-valgrind-headers


