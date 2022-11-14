
[![GitHub package.json version](https://img.shields.io/github/package-json/v/xpack-dev-tools/gcc-xpack)](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/package.json)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/xpack-dev-tools/gcc-xpack)](https://github.com/xpack-dev-tools/gcc-xpack/releases/)
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/gcc.svg?color=blue)](https://www.npmjs.com/package/@xpack-dev-tools/gcc/)
[![license](https://img.shields.io/github/license/xpack-dev-tools/gcc-xpack)](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/LICENSE)

# The xPack GNU Compiler Collection (GCC)

A standalone cross-platform (Windows/macOS/Linux) **GCC**
binary distribution, intended for reproducible builds.

In addition to the the binary archives and the package meta data,
this project also includes the build scripts.

## Overview

This open source project is hosted on GitHub as
[`xpack-dev-tools/gcc-xpack`](https://github.com/xpack-dev-tools/gcc-xpack)
and provides the platform specific binaries for the
[xPack GNU Compiler Collection](https://xpack.github.io/gcc/);
it includes, in addition to project metadata, the full build scripts.

## Release schedule

This distribution generally follows the official
[GNU Compiler Collection](https://gcc.gnu.org) releases.

## User info

This section is intended as a shortcut for those who plan
to use the GCC binaries. For full details please read the
[xPack GNU Compiler Collection](https://xpack.github.io/gcc/) pages.

### Supported languages

The xPack GCC binaries include support for:

- C
- C++
- Obj-C
- Obj-C++
- Fortran

### `-static-libgcc -static-libstdc++`

To avoid issues with shared libraries, specific to toolchains installed
in custom locations, it is highly recommended to use only the
static versions of the GCC libraries.

For this append `-static-libgcc -static-libstdc++` to the linker line.

### Easy install

The easiest way to install GCC is using the **binary xPack**, available as
[`@xpack-dev-tools/gcc`](https://www.npmjs.com/package/@xpack-dev-tools/gcc)
from the [`npmjs.com`](https://www.npmjs.com) registry.

#### Prerequisites

A recent [xpm](https://xpack.github.io/xpm/),
which is a portable [Node.js](https://nodejs.org/) command line application.

It is recommended to update to the latest version with:

```sh
npm install --location=global xpm@latest
```

For details please follow the instructions in the
[xPack install](https://xpack.github.io/install/) page.

#### Install

With the `xpm` tool available, installing
the latest version of the package and adding it as
a dependency for a project is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/gcc@latest

ls -l xpacks/.bin
```

This command will:

- install the latest available version,
into the central xPacks store, if not already there
- add symbolic links to the central store
(or `.cmd` forwarders on Windows) into
the local `xpacks/.bin` folder.

The central xPacks store is a platform dependent
folder; check the output of the `xpm` command for the actual
folder used on your platform).
This location is configurable via the environment variable
`XPACKS_STORE_FOLDER`; for more details please check the
[xpm folders](https://xpack.github.io/xpm/folders/) page.

It is also possible to install GCC globally, in the user home folder:

```sh
xpm install --global @xpack-dev-tools/gcc@latest
```

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/@xpack-dev-tools/gcc/7.1.0-1.1/.content
/Users/ilg/Library/xPacks/@xpack-dev-tools/gcc/7.1.0-1.1/.content
├── README.md
...
```

No other files are installed in any system folders or other locations.

#### Uninstall

To remove the links created by xpm in the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/gcc
```

To completely remove the package from the global store:

```sh
xpm uninstall --global @xpack-dev-tools/gcc
```

### Manual install

For all platforms, the **xPack GNU Compiler Collection**
binaries are released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [Releases](https://github.com/xpack-dev-tools/gcc-xpack/releases/)
page.

For more details please read the
[Install](https://xpack.github.io/gcc/install/) page.

### Versioning

The version strings used by the GCC project are three number strings
like `12.2.0`; to this string the xPack distribution adds a four number,
but since semver allows only three numbers, all additional ones can
be added only as pre-release strings, separated by a dash,
like `12.2.0-1`. When published as a npm package, the version gets
a fifth number, like `12.2.0-1.1`.

Since adherence of third party packages to semver is not guaranteed,
it is recommended to use semver expressions like `^12.2.0` and `~12.2.0`
with caution, and prefer exact matches, like `12.2.0-1.1`.

## Maintainer info

For maintainer info, please see the
[README-MAINTAINER](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-MAINTAINER.md)

## Support

The quick advice for getting support is to use the GitHub
[Discussions](https://github.com/xpack-dev-tools/gcc-xpack/discussions/).

For more details please read the
[Support](https://xpack.github.io/gcc/support/) page.

## License

The original content is released under the
[MIT License](https://opensource.org/licenses/MIT), with all rights
reserved to [Liviu Ionescu](https://github.com/ilg-ul/).

The binary distributions include several open-source components; the
corresponding licenses are available in the installed
`distro-info/licenses` folder.

## Download analytics

- GitHub [`xpack-dev-tools/gcc-xpack`](https://github.com/xpack-dev-tools/gcc-xpack/) repo
  - latest xPack release
[![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/gcc-xpack/latest/total.svg)](https://github.com/xpack-dev-tools/gcc-xpack/releases/)
  - all xPack releases [![Github All Releases](https://img.shields.io/github/downloads/xpack-dev-tools/gcc-xpack/total.svg)](https://github.com/xpack-dev-tools/gcc-xpack/releases/)
  - [individual file counters](https://somsubhra.github.io/github-release-stats/?username=xpack-dev-tools&repository=gcc-xpack) (grouped per release)
- npmjs.com [`@xpack-dev-tools/gcc`](https://www.npmjs.com/package/@xpack-dev-tools/gcc/) xPack
  - latest release, per month
[![npm (scoped)](https://img.shields.io/npm/v/@xpack-dev-tools/gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/gcc/)
[![npm](https://img.shields.io/npm/dm/@xpack-dev-tools/gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/gcc/)
  - all releases [![npm](https://img.shields.io/npm/dt/@xpack-dev-tools/gcc.svg)](https://www.npmjs.com/package/@xpack-dev-tools/gcc/)

Credit to [Shields IO](https://shields.io) for the badges and to
[Somsubhra/github-release-stats](https://github.com/Somsubhra/github-release-stats)
for the individual file counters.
