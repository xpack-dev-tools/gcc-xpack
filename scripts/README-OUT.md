# The xPack GNU Compiler Collection

This is the **xPack** distribution of the **GNU Compiler Collection (GCC)**.

For details, see
[The xPack GNU Compiler Collection](https://xpack.github.io/gcc/) pages.

## Compliance

The xPack GNU Compiler Collection generally follows the official
[GNU Compiler Collection](https://gcc.gnu.org/releases.html) releases.

The tools part of the GNU binutils are not included here and should
be avialable as a separate package.

## Changes

- none

## Build

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[How to build?](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-BUILD.md) page.

## Documentation

The documentation is available locally in `share/docs`,
or [online](https://gcc.gnu.org/onlinedocs/).

## Mingw-w64

The Windows binaries were built in GNU/Linux using the
[Mingw-w64](http://mingw-w64.org/) and should run on Windows 7 and up.

## MacOSX.sdk

In order to obtain a standalone package, the macOS archive includes a copy
of the MacOSX10.10.sdk (partial, since the documentation was excluded).

## More info

For more info and support, please see the xPack project pages from:

  <http://xpack.github.io/dev-tools/gcc>

Thank you for using open source software,

Liviu Ionescu
