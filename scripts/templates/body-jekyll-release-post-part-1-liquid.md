---
title:  xPack GCC {{ RELEASE_VERSION }} released

TODO: select one summary

summary: "Version {{ RELEASE_VERSION }} is a maintenance release; it updates to
the latest upstream master."

summary: "Version {{ RELEASE_VERSION }} is a new release; it follows the upstream release."

version: {{ RELEASE_VERSION }}
npm_subversion: 1
download_url: https://github.com/xpack-dev-tools/gcc-xpack/releases/tag/v{{ RELEASE_VERSION }}/

date:   {{ RELEASE_DATE }}

categories:
  - releases
  - gcc

tags:
  - releases
  - gcc

---

[The xPack GCC](https://xpack.github.io/gcc/)
is a standalone cross-platform binary distribution of
[GCC](http://gcc.org).

There are separate binaries for **Windows** (Intel 32/64-bit),
**macOS** (Intel 64-bit) and **GNU/Linux** (Intel 32/64-bit, Arm 32/64-bit).

{% raw %}{% include note.html content="The main targets for the Arm binaries
are the **Raspberry Pi** class devices." %}{% endraw %}

## Download

The binary files are available from GitHub [releases]({% raw %}{{ page.download_url }}{% endraw %}).

## Prerequisites

- Intel GNU/Linux 32/64-bit: any system with **GLIBC 2.15** or higher
  (like Ubuntu 12 or later, Debian 8 or later, RedHat/CentOS 7 later,
  Fedora 20 or later, etc)
- Arm GNU/Linux 32/64-bit: any system with **GLIBC 2.23** or higher
  (like Ubuntu 16 or later, Debian 9 or later, RedHat/CentOS 8 or later,
  Fedora 24 or later, etc)
- Intel Windows 32/64-bit: Windows 7 with the Universal C Runtime
  ([UCRT](https://support.microsoft.com/en-us/topic/update-for-universal-c-runtime-in-windows-c0514201-7fe6-95a3-b0a5-287930f3560c)),
  Windows 8, Windows 10
- Intel macOS 64-bit: 10.13 or later

## Install

The full details of installing the **xPack GCC** on various platforms
are presented in the separate
[Install]({% raw %}{{ site.baseurl }}{% endraw %}/gcc/install/) page.

### Easy install

The easiest way to install GCC is with
[`xpm`]({% raw %}{{ site.baseurl }}{% endraw %}/xpm/)
by using the **binary xPack**, available as
[`@xpack-dev-tools/gcc`](https://www.npmjs.com/package/@xpack-dev-tools/gcc)
from the [`npmjs.com`](https://www.npmjs.com) registry.

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/gcc@latest

ls -l xpacks/.bin
```

To install this specific version, use:

```sh
xpm install @xpack-dev-tools/gcc@{% raw %}{{ page.version }}.{{ page.npm_subversion }}{% endraw %}
```

It is also possible to install Meson Build globally, in the user home folder,
but this requires xPack aware tools to automatically identify them and
manage paths.

```sh
xpm install --global @xpack-dev-tools/gcc@latest
```

### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/gcc
```

To completely remove the package from the global store:

```sh
xpm uninstall --global @xpack-dev-tools/gcc
```

## Compliance

The xPack GCC generally follows the official
[GCC](http://gcc.org) releases.

The current version is based on:

TODO: update version, URL and date.

- GCC version [11.2.0](https://gcc.gnu.org/gcc-11/) from July 28, 2021.

## Supported languages

The supported languages are:

- C
- C++
- Obj-C
- Obj-C++

Note: Obj-C/C++ support is minimalstic.

## Changes

There are no functional changes.

Compared to the upstream, the following changes were applied:

- a configure option was added to configure branding (`--enable-branding`)
- the `src/gcc.c` file was edited to display the branding string
- the `contrib/60-gcc.rules` file was simplified to avoid protection
  related issues.

## Bug fixes

- none

## Enhancements

- none

## Known problems

- none

## Shared libraries

On all platforms the packages are standalone, and expect only the standard
runtime to be present on the host.

All dependencies that are build as shared libraries are copied locally
in the `libexec` folder (or in the same folder as the executable for Windows).

### `DT_RPATH` and `LD_LIBRARY_PATH`

On GNU/Linux the binaries are adjusted to use a relative path:

```console
$ readelf -d library.so | grep runpath
 0x000000000000001d (RPATH)            Library rpath: [$ORIGIN]
```

In the GNU ld.so search strategy, the `DT_RPATH` has
the highest priority, higher than `LD_LIBRARY_PATH`, so if this later one
is set in the environment, it should not interfere with the xPack binaries.

Please note that previous versions, up to mid-2020, used `DT_RUNPATH`, which
has a priority lower than `LD_LIBRARY_PATH`, and does not tolerate setting
it in the environment.

### `@executable_path`

Similarly, on macOS, the dynamic libraries are adjusted with `otool` to use a
relative path.

## Documentation

The original documentation is available in the `share/doc` folder.

## Build

The binaries for all supported platforms
(Windows, macOS and Intel & Arm GNU/Linux) were built using the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/), a set
of build environments based on slightly older distributions, that should be
compatible with most recent systems.

The scripts used to build this distribution are in:

- `distro-info/scripts`

For the prerequisites and more details on the build procedure, please see the
[How to build](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-BUILD.md) page.

## CI tests

Before publishing, a set of simple tests were performed on an exhaustive
set of platforms. The results are available from:

- [GitHub Actions](https://github.com/xpack-dev-tools/gcc-xpack/actions/)
- [travis-ci.com](https://app.travis-ci.com/github/xpack-dev-tools/gcc-xpack/builds/)

## Tests

The binaries were tested on a variety of platforms,
but mainly to check the integrity of the
build, not the compiler functionality.

## Checksums

The SHA-256 hashes for the files are:
