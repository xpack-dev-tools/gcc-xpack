# NOTES

## GCC 11 on macOS 14

/Users/ilg/Work/xpack-dev-tools-build/gcc-11.4.0-2/darwin-x64/sources/gdb-13.2/missing: line 81: makeinfo: command not found
WARNING: 'makeinfo' is missing on your system.
         You should only need it if you modified a '.texi' file, or
         any other file indirectly affecting the aspect of the manual.
         You might want to install the Texinfo package:
         <http://www.gnu.org/software/texinfo/>
         The spurious makeinfo call might also be the consequence of
         using a buggy 'make' (AIX, DU, IRIX), in which case you might
         want to install GNU make:
         <http://www.gnu.org/software/make/>
make[2]: *** [doc/bfd.info] Error 127
make[1]: *** [info-recursive] Error 1
make: *** [all-bfd] Error 2
make: *** Waiting for unfinished jobs....
