# How to build the xPack GCC binaries

## Introduction

This project also includes the scripts and additional files required to
build and publish the
[xPack GNU Compiler Collection](https://github.com/xpack-dev-tools/gcc-xpack) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://xpack.github.io/xbb/),
a set of elaborate build environments based on recent GCC versions
(Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

There are two types of builds:

- **local/native builds**, which use the tools available on the
  host machine; generally the binaries do not run on a different system
  distribution/version; intended mostly for development purposes;
- **distribution builds**, which create the archives distributed as
  binaries; expected to run on most modern systems.

This page documents the distribution builds.

For native builds, see the `build-native.sh` script. (to be added)

## Repositories

- <https://github.com/xpack-dev-tools/gcc-xpack.git> -
  the URL of the xPack build scripts repository
- <https://github.com/xpack-dev-tools/build-helper> - the URL of the
  xPack build helper, used as the `scripts/helper` submodule.
- <https://gcc.gnu.org/git/?p=gcc.git;a=tree> - the main repo

### Branches

- `xpack` - the updated content, used during builds
- `xpack-develop` - the updated content, used during development
- `master` - the original content; it follows the upstream master.

## Prerequisites

The prerequisites are common to all binary builds. Please follow the
instructions in the separate
[Prerequisites for building binaries](https://xpack.github.io/xbb/prerequisites/)
page and return when ready.

Note: Building the Arm binaries requires an Arm machine.

## Download the build scripts

The build scripts are available in the `scripts` folder of the
[`xpack-dev-tools/gcc-xpack`](https://github.com/xpack-dev-tools/gcc-xpack)
Git repo.

To download them, use the following commands:

```sh
rm -rf ~/Downloads/gcc-xpack.git; \
git clone https://github.com/xpack-dev-tools/gcc-xpack.git \
  ~/Downloads/gcc-xpack.git; \
git -C ~/Downloads/gcc-xpack.git submodule update --init --recursive
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

To use the `xpack-develop` branch of the build scripts, issue:

```sh
rm -rf ~/Downloads/gcc-xpack.git; \
git clone \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/gcc-xpack.git \
  ~/Downloads/gcc-xpack.git; \
git -C ~/Downloads/gcc-xpack.git submodule update --init --recursive
```

## The `Work` folder

The scripts create a temporary build `Work/gcc-${version}` folder in
the user home. Although not recommended, if for any reasons you need to
change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

## Spaces in folder names

Due to the limitations of `make`, builds started in folders with
spaces in names are known to fail.

If on your system the work folder is in such a location, redefine it in a
folder without spaces and set the `WORK_FOLDER_PATH` variable before invoking
the script.

## Customizations

There are many other settings that can be redefined via
environment variables. If necessary,
place them in a file and pass it via `--env-file`. This file is
either passed to Docker or sourced to shell. The Docker syntax
**is not** identical to shell, so some files may
not be accepted by bash.

## Versioning

The version string is an extension to semver, the format looks like `11.2.0-2`.
It includes the three digits with the original GCC version and a fourth
digit with the xPack release number.

When publishing on the **npmjs.com** server, a fifth digit is appended.

## Changes

Compared to the original GNU Compiler Collection distribution,
there should be no functional changes.

The actual changes for each version are documented in the
release web pages.

## How to build local/native binaries

### README-DEVELOP.md

The details on how to prepare the development environment for
GNU Compiler Collection are in the
[`README-DEVELOP.md`](https://github.com/xpack-dev-tools/gcc-xpack/blob/xpack/README-DEVELOP.md) file.

## How to build distributions

## Build

The builds currently run on 3 dedicated machines (Intel GNU/Linux,
Arm GNU/Linux and Intel macOS). A fourth machine for Arm macOS is planned.

### Build the Intel GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is a
Debian 10, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD. The machine name is `xbbli`.

```sh
caffeinate ssh xbbli
```

Before starting a build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY       TAG                    IMAGE ID       CREATED         SIZE
ilegeul/ubuntu   amd64-18.04-xbb-v3.4   ace5ae2e98e5   4 weeks ago     5.11GB
```

It is also recommended to Remove unused Docker space. This is mostly useful
after failed builds, during development, when dangling images may be left
by Docker.

To check the content of a Docker image:

```sh
docker run --interactive --tty ilegeul/ubuntu:amd64-18.04-xbb-v3.4
```

To remove unused files:

```sh
docker system prune --force
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S gcc

sudo rm -rf ~/Work/gcc-*
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --all
```

or, for development builds:

```sh
sudo rm -rf ~/Work/gcc-*
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --without-pdf --without-html --disable-tests --linux64 --win64
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 110 minutes later, the output of the build script is a set of 4
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/gcc-*/deploy
total 247864
-rw-rw-r--  1 1000  1000   94916876 Jul 31 21:23 xpack-gcc-11.2.0-2-linux-x64.tar.gz
-rw-rw-r--  1 1000  1000        101 Jul 31 21:23 xpack-gcc-11.2.0-2-linux-x64.tar.gz.sha
-rw-rw-r--  1 1000  1000  107954359 Jul 31 22:36 xpack-gcc-11.2.0-2-win32-ia32.zip
-rw-rw-r--  1 1000  1000         99 Jul 31 22:36 xpack-gcc-11.2.0-2-win32-ia32.zip.sha
-rw-rw-r--  1 1000  1000  112626193 Jul 31 21:41 xpack-gcc-11.2.0-2-win32-x64.zip
-rw-rw-r--  1 1000  1000         98 Jul 31 21:41 xpack-gcc-11.2.0-2-win32-x64.zip.sha
```

### Build the Arm GNU/Linux binaries

The supported Arm architectures are:

- `armhf` for 32-bit devices
- `aarch64` for 64-bit devices

The current platform for Arm GNU/Linux production builds is a
Raspberry Pi OS 10, running on a Raspberry Pi Compute Module 4, with
8 GB of RAM and 256 GB of fast M.2 SSD. The machine name is `xbbla`.

```sh
caffeinate ssh xbbla
```

Before starting a build, check if Docker is started:

```sh
docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY       TAG                      IMAGE ID       CREATED          SIZE
ilegeul/ubuntu   arm32v7-16.04-xbb-v3.3   a0ceaa6dad05   57 minutes ago   3.34GB
ilegeul/ubuntu   arm64v8-16.04-xbb-v3.3   1b0b4a94de6d   13 hours ago     3.6GB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```sh
screen -S gcc

sudo rm -rf ~/Work/gcc-*
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --all
```

or, for development builds:

```sh
sudo rm -rf ~/Work/gcc-*
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --without-pdf --without-html --disable-tests --arm64 --arm32
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 290 minutes later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ ls -l ~/Work/gcc-*/deploy
total 158536
-rw-rw-r-- 1 ilg ilg 84148158 Jul 31 20:58 xpack-gcc-11.2.0-2-linux-arm64.tar.gz
-rw-rw-r-- 1 ilg ilg      103 Jul 31 20:58 xpack-gcc-11.2.0-2-linux-arm64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 78181315 Jul 31 23:26 xpack-gcc-11.2.0-2-linux-arm.tar.gz
-rw-rw-r-- 1 ilg ilg      101 Jul 31 23:26 xpack-gcc-11.2.0-2-linux-arm.tar.gz.sha
```

### Build the macOS binaries

The current platforms for macOS production builds are:

- a macOS 10.13.6 running on a MacBook Pro 2011 with 32 GB of RAM and
  a fast SSD; the machine name is `xbbmi`
- a macOS 11.6.1 running on a Mac Mini M1 2020 with 16 GB of RAM;
  the machine name is `xbbma`

```sh
caffeinate ssh xbbmi

caffeinate ssh xbbma
```

To build the latest macOS version:

```sh
screen -S gcc

rm -rf ~/Work/gcc-*
caffeinate bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --macos
```

or, for development builds:

```sh
rm -rf ~/Work/gcc-arm-*
caffeinate bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --develop --without-pdf --without-html --disable-tests --macos
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-\` or
`Ctrl-a` `Ctrl-k` and confirm.

About 60 minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ ls -l ~/Work/gcc-*/deploy
total 163376
-rw-r--r--  1 ilg  staff  66170610 Jul 31 21:01 xpack-gcc-11.2.0-2-darwin-x64.tar.gz
-rw-r--r--  1 ilg  staff       102 Jul 31 21:01 xpack-gcc-11.2.0-2-darwin-x64.tar.gz.sha
```

## Subsequent runs

### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```console
--linux64 --win64
```

On Arm, instead of `--all`, you can use any combination of:

```console
--arm32 --arm64
```

### `clean`

To remove most build temporary files, use:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --all clean
```

To also remove the library build temporary files, use:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --all cleanlibs
```

To remove all temporary files, use:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/helper/build.sh --all cleanall
```

Instead of `--all`, any combination of `--win64 --linux64`
will remove the more specific folders.

For production builds it is recommended to completely remove the build folder.

### `--develop`

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in
the host file system, and resume an interrupted build.

### `--debug`

For development builds, it is also possible to create everything with
`-g -O0` and be able to run debug sessions.

### --jobs

By default, the build steps use all available cores. If, for any reason,
parallel builds fail, it is possible to reduce the load.

### Interrupted builds

The Docker scripts run with root privileges. This is generally not a
problem, since at the end of the script the output files are reassigned
to the actual user.

However, for an interrupted build, this step is skipped, and files in
the install folder will remain owned by root. Thus, before removing
the build folder, it might be necessary to run a recursive `chown`.

## Testing

A simple test is performed by the script at the end, by launching the
executable to check if all shared/dynamic libraries are correctly used.

For a true test you need to unpack the archive in a temporary location
(like `~/Downloads`) and then run the
program from there. For example on macOS the output should
look like:

```console
$ .../xpack-gcc-11.2.0-2/gcc/bin/gcc --version
gcc (xPack GCC x86_64) 11.2.0
Copyright (C) 2018 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Installed folders

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@xpack-dev-tools/gcc/11.2.0-2.1/.content/
/Users/ilg/Library/xPacks/@xpack-dev-tools/gcc/11.2.0-2.1/.content/
├── README.md
├── bin
│   ├── c++
│   ├── cpp
│   ├── g++
│   ├── gcc
│   ├── gcov
│   ├── gcov-dump
│   └── gcov-tool
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   └── c++
├── lib
│   ├── gcc
│   ├── libasan.5.dylib
│   ├── libasan.dylib -> libasan.5.dylib
│   ├── libasan.la
│   ├── libasan_preinit.o
│   ├── libatomic.1.dylib
│   ├── libatomic.a
│   ├── libatomic.dylib -> libatomic.1.dylib
│   ├── libatomic.la
│   ├── libcc1.0.so
│   ├── libcc1.a
│   ├── libcc1.la
│   ├── libcc1.so -> libcc1.0.so
│   ├── libgcc_ext.10.4.dylib
│   ├── libgcc_ext.10.5.dylib
│   ├── libgcc_s.1.dylib
│   ├── libgcc_s_ppc64.1.dylib -> libgcc_s.1.dylib
│   ├── libgcc_s_x86_64.1.dylib -> libgcc_s.1.dylib
│   ├── libgomp.1.dylib
│   ├── libgomp.a
│   ├── libgomp.dylib -> libgomp.1.dylib
│   ├── libgomp.la
│   ├── libgomp.spec
│   ├── libitm.1.dylib
│   ├── libitm.a
│   ├── libitm.dylib -> libitm.1.dylib
│   ├── libitm.la
│   ├── libitm.spec
│   ├── libquadmath.0.dylib
│   ├── libquadmath.a
│   ├── libquadmath.dylib -> libquadmath.0.dylib
│   ├── libquadmath.la
│   ├── libsanitizer.spec
│   ├── libssp.0.dylib
│   ├── libssp.a
│   ├── libssp.dylib -> libssp.0.dylib
│   ├── libssp.la
│   ├── libssp_nonshared.a
│   ├── libssp_nonshared.la
│   ├── libstdc++.6.dylib
│   ├── libstdc++.a
│   ├── libstdc++.a-gdb.py
│   ├── libstdc++.dylib -> libstdc++.6.dylib
│   ├── libstdc++.la
│   ├── libstdc++fs.a
│   ├── libstdc++fs.la
│   ├── libsupc++.a
│   ├── libsupc++.la
│   ├── libubsan.1.dylib
│   ├── libubsan.dylib -> libubsan.1.dylib
│   └── libubsan.la
├── libexec
│   ├── gcc
│   ├── libgcc_s.1.dylib
│   ├── libgmp.10.dylib
│   ├── libisl.15.dylib
│   ├── libmpc.3.dylib
│   ├── libmpfr.4.dylib
│   ├── libstdc++.6.dylib
│   ├── libz.1.2.11.dylib
│   └── libz.1.dylib -> libz.1.2.11.dylib
└── share
    ├── doc
    └── gcc-11.2.0

14 directories, 67 files
```

No other files are installed in any system folders or other locations.

## Uninstall

The binaries are distributed as portable archives; thus they do not need
to run a setup and do not require an uninstall; simply removing the
folder is enough.

## Files cache

The XBB build scripts use a local cache such that files are downloaded only
during the first run, later runs being able to use the cached files.

However, occasionally some servers may not be available, and the builds
may fail.

The workaround is to manually download the files from an alternate
location (like
<https://github.com/xpack-dev-tools/files-cache/tree/master/libs>),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on
the host, with `build.sh`, which runs `container-build.sh` several
times, once for each target, in one of the two docker containers.
Both scripts include several other helper scripts. The entire process
is quite complex, and an attempt to explain its functionality in a few
words would not be realistic. Thus, the authoritative source of details
remains the source code.
