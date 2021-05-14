# How to build the xPack GNU Compiler Collection?

## Introduction

This project also includes the scripts and additional files required to
build and publish the
[xPack GNU Compiler Collection](https://github.com/xpack-dev-tools/gcc-xpack) binaries.

The build scripts use the
[xPack Build Box (XBB)](https://github.com/xpack/xpack-build-box),
a set of elaborate build environments based on recent GCC versions
(Docker containers
for GNU/Linux and Windows or a custom folder for MacOS).

## Repositories

- `https://github.com/xpack-dev-tools/gcc-xpack.git` - the URL of the Git
repository

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

To download them, the following shortcut is available:

```console
$ curl -L https://github.com/xpack-dev-tools/gcc-xpack/raw/xpack/scripts/git-clone.sh | bash
```

This small script issues the following two commands:

```console
$ rm -rf ~/Downloads/gcc-xpack.git
$ git clone --recurse-submodules \
  https://github.com/xpack-dev-tools/gcc-xpack.git \
  ~/Downloads/gcc-xpack.git
```

> Note: the repository uses submodules; for a successful build it is
> mandatory to recurse the submodules.

To use the `xpack-develop` branch of the build scripts, use:

```console
$ rm -rf ~/Downloads/gcc-xpack.git
$ git clone --recurse-submodules --branch xpack-develop \
  https://github.com/xpack-dev-tools/gcc-xpack.git \
  ~/Downloads/gcc-xpack.git
```

## The `Work` folder

The scripts create a temporary build `Work/gcc-${version}` folder in
the user home. Although not recommended, if for any reasons you need to
change the location of the `Work` folder,
you can redefine `WORK_FOLDER_PATH` variable before invoking the script.

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

### Update git repos

To keep the main branch in sync with the development branch,
in the `xpack-dev-tools/gcc-xpack` Git repo:

- checkout `xpack`
- merge `xpack-develop`

No need to add a tag here, it'll be added when the release is created.

### Prepare release

To prepare a new release, first determine the GNU Compiler Collection version
(like `8.4.0`) and update the `scripts/VERSION` file. The format is
`8.4.0-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

Add a new set of definitions in the `scripts/common-versions-source.sh`, with
the versions of various components.

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific file (below).

### Create `README-<version>.md`

In the `scripts` folder create a copy of the previous one and update the
Git commit and possible other details.

### Update `CHANGELOG.md`

Check `CHANGELOG.md` and add the new release.

### Build

Although it is perfectly possible to build all binaries in a single step
on a macOS system, due to Docker specifics, it is faster to build the
GNU/Linux and Windows binaries on a GNU/Linux system and the macOS binary
separately on a macOS system.

#### Build the Intel GNU/Linux and Windows binaries

The current platform for GNU/Linux and Windows production builds is an
Manjaro 19, running on an Intel NUC8i7BEH mini PC with 32 GB of RAM
and 512 GB of fast M.2 SSD.

```console
$ ssh xbbi
```

Before starting a build, check if Docker is started:

```console
$ docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```console
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                    IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      i386-12.04-xbb-v3.1    6274c178b54c        5 days ago          3.7GB
ilegeul/ubuntu      amd64-12.04-xbb-v3.1   3846ecf3ba1a        5 days ago          4.07GB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S gcc

$ sudo rm -rf ~/Work/gcc-*
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 30 minutes later, the output of the build script is a set of 4
archives and their SHA signatures, created in the `deploy` folder:

```console
$ cd ~/Work/gcc-*
$ ls -l deploy
total 97556
-rw-rw-r-- 1 ilg ilg 24496098 Apr 15 21:31 xpack-gcc-8.4.0-1-linux-x32.tar.gz
-rw-rw-r-- 1 ilg ilg      104 Apr 15 21:31 xpack-gcc-8.4.0-1-linux-x32.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 23333236 Apr 15 21:08 xpack-gcc-8.4.0-1-linux-x64.tar.gz
-rw-rw-r-- 1 ilg ilg      104 Apr 15 21:08 xpack-gcc-8.4.0-1-linux-x64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 24638346 Apr 15 21:43 xpack-gcc-8.4.0-1-win32-x32.zip
-rw-rw-r-- 1 ilg ilg      101 Apr 15 21:43 xpack-gcc-8.4.0-1-win32-x32.zip.sha
-rw-rw-r-- 1 ilg ilg 27402794 Apr 15 21:21 xpack-gcc-8.4.0-1-win32-x64.zip
-rw-rw-r-- 1 ilg ilg      101 Apr 15 21:21 xpack-gcc-8.4.0-1-win32-x64.zip.sha
```

To copy the files from the build machine to the current development
machine, either use NFS to mount the entire folder, or open the `deploy`
folder in a terminal and use `scp`:

```console
$ cd ~/Work/gcc-*
$ cd deploy
$ scp * ilg@wks:Downloads/xpack-binaries/gcc
```

#### Build the Arm GNU/Linux binaries

The current platform for GNU/Linux and Windows production builds is an
Manjaro 19, running on an Raspberry Pi 4B with 4 GB of RAM
and 256 GB of fast M.2 SSD.

```console
$ ssh xbba
$ ssh berry
```

Before starting a build, check if Docker is started:

```console
$ docker info
```

Before running a build for the first time, it is recommended to preload the
docker images.

```console
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh preload-images
```

The result should look similar to:

```console
$ docker images
REPOSITORY          TAG                            IMAGE ID            CREATED             SIZE
ilegeul/ubuntu      arm32v7-16.04-xbb-v3.1         e08db859d5e9        4 days ago          2.97GB
ilegeul/ubuntu      arm64v8-16.04-xbb-v3.1         7ea793693fcc        5 days ago          3.15GB
```

Since the build takes a while, use `screen` to isolate the build session
from unexpected events, like a broken
network connection or a computer entering sleep.

```console
$ screen -S gcc

$ sudo rm -rf ~/Work/gcc-*
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-k` and confirm.

About 55 minutes later, the output of the build script is a set of 2
archives and their SHA signatures, created in the `deploy` folder:

```console
$ cd ~/Work/gcc-*
$ ls -l deploy
total 43124
-rw-rw-r-- 1 ilg ilg 22213055 Apr 15 21:59 xpack-gcc-8.4.0-1-linux-arm64.tar.gz
-rw-rw-r-- 1 ilg ilg      106 Apr 15 21:59 xpack-gcc-8.4.0-1-linux-arm64.tar.gz.sha
-rw-rw-r-- 1 ilg ilg 21933918 Apr 15 23:02 xpack-gcc-8.4.0-1-linux-arm.tar.gz
-rw-rw-r-- 1 ilg ilg      104 Apr 15 23:02 xpack-gcc-8.4.0-1-linux-arm.tar.gz.sha
```

To copy the files from the build machine to the current development
machine, either use NFS to mount the entire folder, or open the `deploy`
folder in a terminal and use `scp`:

```console
$ cd ~/Work/gcc-*/deploy
$ scp * ilg@wks:Downloads/xpack-binaries/gcc
```

#### Build the macOS binaries

The current platform for macOS production builds is a macOS 10.10.5
running on a MacBook Pro with 32 GB of RAM and a fast SSD.

```console
$ ssh xbbm
```

To build the latest macOS version:

```console
$ screen -S gcc

$ rm -rf ~/Work/gcc-*
$ caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --osx
```

To detach from the session, use `Ctrl-a` `Ctrl-d`; to reattach use
`screen -r gcc`; to kill the session use `Ctrl-a` `Ctrl-\` or
`Ctrl-a` `Ctrl-k` and confirm.

Several minutes later, the output of the build script is a compressed
archive and its SHA signature, created in the `deploy` folder:

```console
$ cd ~/Work/gcc-*
$ ls -l deploy
total 30720
-rw-r--r--  1 ilg  staff  15721827 Apr 14 19:50 xpack-gcc-8.4.0-1-darwin-x64.tar.gz
-rw-r--r--  1 ilg  staff       105 Apr 14 19:50 xpack-gcc-8.4.0-1-darwin-x64.tar.gz.sha
```

To copy the files from the build machine to the current development
machine, either use NFS to mount the entire folder, or open the `deploy`
folder in a terminal and use `scp`:

```console
$ cd ~/Work/gcc-*
$ cd deploy
$ scp * ilg@wks:Downloads/xpack-binaries/gcc
```

### Subsequent runs

#### Separate platform specific builds

Instead of `--all`, you can use any combination of:

```
--win32 --win64 --linux32 --linux64
--arm --arm64
```

#### `clean`

To remove most build temporary files, use:

```console
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all clean
```

To also remove the library build temporary files, use:

```console
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all cleanlibs
```

To remove all temporary files, use:

```console
$ bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all cleanall
```

Instead of `--all`, any combination of `--win32 --win64 --linux32 --linux64`
will remove the more specific folders.

For production builds it is recommended to completely remove the build folder.

#### `--develop`

For performance reasons, the actual build folders are internal to each
Docker run, and are not persistent. This gives the best speed, but has
the disadvantage that interrupted builds cannot be resumed.

For development builds, it is possible to define the build folders in
the host file system, and resume an interrupted build.

#### `--debug`

For development builds, it is also possible to create everything with
`-g -O0` and be able to run debug sessions.

#### Interrupted builds

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
$ /Users/ilg/Work/gcc-8.4.0-1/darwin-x64/install/gcc/bin/gcc --version
gcc version 8.4.0
```

## Installed folders

After install, the package should create a structure like this (macOS files;
only the first two depth levels are shown):

```console
$ tree -L 2 /Users/ilg/Library/xPacks/\@xpack-dev-tools/gcc/8.4.0-1.1/.content/
/Users/ilg/Library/xPacks/\@xpack-dev-tools/gcc/8.4.0-1.1/.content/
├── README.md
├── bin
│   ├── cgcc
│   ├── gcc
│   ├── cpack
│   ├── ctest
│   ├── libc++.1.dylib
│   ├── libc++abi.dylib
│   ├── libgcc_s.1.dylib
│   └── libncurses.6.dylib
├── distro-info
│   ├── licenses
│   ├── patches
│   └── scripts
└── share
    ├── aclocal
    └── gcc-3.17

8 directories, 9 files
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
https://github.com/xpack-dev-tools/files-cache/tree/master/libs),
place them in the XBB cache (`Work/cache`) and restart the build.

## More build details

The build process is split into several scripts. The build starts on
the host, with `build.sh`, which runs `container-build.sh` several
times, once for each target, in one of the two docker containers.
Both scripts include several other helper scripts. The entire process
is quite complex, and an attempt to explain its functionality in a few
words would not be realistic. Thus, the authoritative source of details
remains the source code.

## TODO

- if XBB mingw GCC will support ObjC & Fortran, enable for mingw too.
