---

title: The xPack GNU Compiler Collection (GCC)
permalink: /dev-tools/gcc/

summary: "A binary distribution of the GNU Compiler Collection."
keywords:
  - gnu
  - gcc
  - c++

comments: true

date: 2021-05-22 00:27:00 +0300

redirect_to: https://xpack-dev-tools.github.io/gcc-xpack/

---

## Quicklinks

If you already know the general facts about the xPack GNU Compiler Collection, you can
directly skip to the desired pages.

User pages:

- [install]({{ site.baseurl }}/gcc/install/)
- [support]({{ site.baseurl }}/gcc/support/)
- [releases]({{ site.baseurl }}/gcc/releases/)

Developer & maintainer pages:

- [GitHub](https://github.com/xpack-dev-tools/gcc-xpack/)
- [README-MAINTAINER](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-MAINTAINER.md)

## Overview

The **xPack GNU Compiler Collection**
is an cross-platform standalone binary distribution of the
[GNU Compiler Collection](https://gcc.gnu.org).

## Benefits

The main advantages of using the **xPack GNU Compiler Collection** are:

- a convenient, uniform and portable install/uninstall/upgrade procedure,
  the same procedure is used for all major
  platforms (Intel Windows 64-bit, Intel GNU/Linux 64-bit, Arm GNU/Linux
  64/32-bit, Intel macOS 64-bit, Apple Silicon macOS 64-bit)
- a convenient integration with Continuous Integration environments,
  like GitHub Actions
- a better integration with development environments
  like **Eclipse Embedded CDT**.

All binaries are self-contained, they include all required libraries,
and can be installed in any location.

## Compatibility

The **xPack GNU Compiler Collection** is fully compatible with the
original GNU releases.

## Install

The details of installing the **xPack GNU Compiler Collection** on various
platforms are presented in the separate
[install]({{ site.baseurl }}/gcc/install/) page.

## Documentation

To save space and bandwidth, the original documentation is available
[online](https://gcc.gnu.org/onlinedocs/).

## Predefined macros

The list of build-in macros is available in a
[separate page]({{ site.baseurl }}/gcc/predefined-macros/).

## Support

For the various support options, please read the separate
[support]({{ site.baseurl }}/gcc/support/) page.

## Change log

The release and change log is available in the repository
[`CHANGELOG.md`](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/CHANGELOG.md) file.

## Build details

For those interested in building the binaries, please read the
[README-MAINTAINER](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-MAINTAINER.md)
page.
However, the ultimate source for details are the build scripts themselves,
all available from the
[`gcc-xpack.git/scripts`](https://github.com/xpack-dev-tools/gcc-xpack/tree/xpack/scripts/)
folder.

## Releases

See the [releases]({{ site.baseurl }}/gcc/releases/) pages.

## Tests reports

- [14.1.0-1]({{ site.baseurl }}/gcc/tests/14.1.0-1/)
- [13.3.0-1]({{ site.baseurl }}/gcc/tests/13.3.0-1/)
- [12.4.0-1]({{ site.baseurl }}/gcc/tests/12.4.0-1/)
- [11.5.0-1]({{ site.baseurl }}/gcc/tests/11.5.0-1/)
