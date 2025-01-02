---

title: How to install the xPack GNU Compiler Collection binaries
permalink: /dev-tools/gcc/install/

summary: "The recommended method is via xpm."

version: "12.1.0"
xpack-subversion: "1"

comments: true
toc: false

date: 2021-05-22 00:27:00 +0300

redirect_to: https://xpack-dev-tools.github.io/gcc-xpack/docs/install/

---

## Overview

The **xPack GNU Compiler Collection** can be installed automatically,
via `xpm` (the recommended method), or manually,
by downloading and unpacking one of the portable archives.

{% capture easy_install %}

## Easy install

The easiest way to install the xPack GNU Compiler Collection is by using the
**binary xPack**, available as
[`@xpack-dev-tools/gcc`](https://www.npmjs.com/package/@xpack-dev-tools/gcc)
from the [`npmjs.com`](https://www.npmjs.com) registry.

### Prerequisites

The only requirement is a recent
`xpm`, which is a portable
[Node.js](https://nodejs.org) command line application. To install it,
follow the instructions from the
[xpm install]({{ site.baseurl }}/xpm/install/) page.

### Install

With xpm available, installing
the latest version of the package is quite easy:

```sh
cd my-project
xpm init # Only at first use.

xpm install @xpack-dev-tools/gcc@latest --verbose
```

This command will always install the latest available version,
in the global xPacks store, which is a platform dependent folder
(check the output of the `xpm` command for the actual folder used on
your platform).

{% capture include_1 %}
The install location can be configured using the
`XPACKS_STORE_FOLDER` environment variable; for more details please check the
[xpm folders]({{ site.baseurl }}/xpm/folders/) page.
{% endcapture %}

{% include tip.html content=include_1 %}

{% include tip.html content="The archive content is unpacked into a folder
named `.content`. On some platforms
this might be hidden for normal browsing, and require
separate options (like `ls -A`) or, in file browsers, to enable
settings like **Show Hidden Files**." %}

### Update

For the moment, to update the package, try to install the latest release again,
as shown before. If there is a new release, it will be installed,
otherwise a message will warn that the package is already installed.

Future versions of xpm will implement the `outdated` and `update` commands,
as npm does.

### Uninstall

To remove the links from the current project:

```sh
cd my-project

xpm uninstall @xpack-dev-tools/gcc
```

To completely remove the package from the central xPacks store:

```sh
xpm uninstall --global @xpack-dev-tools/gcc
```

{% endcapture %}

{% capture manual_install %}

## Manual install

For all platforms, the **xPack GNU Compiler Collection** binaries are
released as portable
archives that can be installed in any location.

The archives can be downloaded from the
GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases/) pages.
{% endcapture %}

{% capture windows %}

{{ easy_install }}

### Test

To check if the xpm installed GCC starts, use something like:

```doscon
C:\>%USERPROFILE%\AppData\Roaming\xPacks\@xpack-dev-tools\gcc\{{ page.version }}-{{ page.xpack-subversion }}.1\.content\bin\gcc.exe" --version
gcc (xPack GCC x86_64) {{ page.version }}
```

{{ manual_install }}

### Download

The Windows versions of **xPack GNU Compiler Collection**
are packed as ZIP files.
Download the latest version named like:

- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-win32-x64.zip`

{% include note.html content="In case you wonder where the suffix comes
from, it is exactly the Node.js `process.platform` and `process.arch`.
The `win32` part is confusing, but we have to live with it." %}

### Unpack

To manually install the xPack GNU Compiler Collection,
unpack the archive and copy the versioned folder into the
`%USERPROFILE%\AppData\Roaming\xPacks\gcc`
(for example `C:\Users\ilg\AppData\Roaming\xPacks\gcc`) folder;
according to Microsoft, `AppData\Roaming` is the recommended location for
installing user specific packages.

You may shorten the last folder name and keep only the version.

{% include note.html content="For manual installs, the recommended
install location is slightly different from the xpm install folders,
which use the scope (like `@xpack-dev-tools`) to group different tools,
and `.content` to store the unpacked archive." %}

### Test

To check if the manually installed GCC starts, use something like:

```doscon
C:\>%USERPROFILE%\AppData\Roaming\xPacks\gcc\xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}\bin\gcc.exe" --version
gcc (xPack GCC x86_64) {{ page.version }}
```

{% endcapture %}

{% capture macos %}

{{ easy_install }}

### Test

To check if the xpm installed GCC starts, use something like:

```console
$ ~/Library/xPacks/@xpack-dev-tools/gcc/{{ page.version }}-{{ page.xpack-subversion }}.1/.content/bin/gcc --version
gcc (xPack GCC x86_64) {{ page.version }}
```

{{ manual_install }}

### Download

The macOS versions of **xPack GNU Compiler Collection** are packed as a
`.tar.gz` archive.
Download the latest version named like:

- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-darwin-x64.tar.gz`
- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-darwin-arm64.tar.gz`

### Unpack

To manually install the xPack GNU Compiler Collection,
unpack the archive and copy it to
`~/.local/xPacks/gcc/xpack-gcc-<version>`:

```sh
mkdir -p ~/.local/xPacks/gcc
cd ~/.local/xPacks/gcc

tar xvf ~/Downloads/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-darwin-x64.tar.gz
chmod -R -w xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
```

You may shorten the last folder name and keep only the version.

{% include note.html content="For manual installs, the recommended
install location is different from the xpm install folders." %}

The result is a structure like:

```console
$ tree -L 2 /Users/ilg/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
/Users/ilg/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
├── README.md
├── bin
│   ├── c++
│   ├── cpp
│   ├── g++
│   ├── gcc
│   ├── gcov
│   ├── gcov-dump
│   ├── gcov-tool
│   ├── gdb
│   ├── gdb-add-index
│   ├── lto-dump
│   ├── x86_64-apple-darwin21.4.0-c++
│   ├── x86_64-apple-darwin21.4.0-g++
│   ├── x86_64-apple-darwin21.4.0-gcc
│   ├── x86_64-apple-darwin21.4.0-gcc-{{ page.version }}
│   ├── x86_64-apple-darwin21.4.0-gcc-ar
│   ├── x86_64-apple-darwin21.4.0-gcc-nm
│   └── x86_64-apple-darwin21.4.0-gcc-ranlib
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   ├── c++
│   └── gdb
├── lib
│   ├── gcc
│   ├── libasan.8.dylib
│   ├── libasan.dylib -> libasan.8.dylib
│   ├── libasan.la
│   ├── libasan_preinit.o
│   ├── libatomic.1.dylib
│   ├── libatomic.a
│   ├── libatomic.dylib -> libatomic.1.dylib
│   ├── libatomic.la
│   ├── libcc1.0.so
│   ├── libcc1.a
│   ├── libcc1.la
│   ├── libcc1.so -> libcc1.0.so
│   ├── libgcc_s.1.1.dylib
│   ├── libgcc_s.1.dylib
│   ├── libgomp.1.dylib
│   ├── libgomp.a
│   ├── libgomp.dylib -> libgomp.1.dylib
│   ├── libgomp.la
│   ├── libgomp.spec
│   ├── libitm.1.dylib
│   ├── libitm.a
│   ├── libitm.dylib -> libitm.1.dylib
│   ├── libitm.la
│   ├── libitm.spec
│   ├── libquadmath.0.dylib
│   ├── libquadmath.a
│   ├── libquadmath.dylib -> libquadmath.0.dylib
│   ├── libquadmath.la
│   ├── libsanitizer.spec
│   ├── libssp.0.dylib
│   ├── libssp.a
│   ├── libssp.dylib -> libssp.0.dylib
│   ├── libssp.la
│   ├── libssp_nonshared.a
│   ├── libssp_nonshared.la
│   ├── libstdc++.6.dylib
│   ├── libstdc++.6.dylib-gdb.py
│   ├── libstdc++.a
│   ├── libstdc++.dylib -> libstdc++.6.dylib
│   ├── libstdc++.la
│   ├── libstdc++fs.a
│   ├── libstdc++fs.la
│   ├── libsupc++.a
│   ├── libsupc++.la
│   ├── libubsan.1.dylib
│   ├── libubsan.dylib -> libubsan.1.dylib
│   └── libubsan.la
├── libexec
│   ├── gcc
│   ├── libexpat.1.8.8.dylib
│   ├── libexpat.1.dylib -> libexpat.1.8.8.dylib
│   ├── libgcc_s.1.1.dylib
│   ├── libgcc_s.1.dylib
│   ├── libgmp.10.dylib
│   ├── libiconv.2.dylib
│   ├── libisl.23.dylib
│   ├── libmpc.3.dylib
│   ├── libmpfr.6.dylib
│   ├── libncursesw.6.dylib
│   └── libstdc++.6.dylib
└── share
    ├── doc
    ├── gcc-{{ page.version }}
    └── gdb

16 directories, 77 files
```

### Test

To check if the manually installed GCC starts, use something like:

```console
$ ~/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}.1/bin/gcc --version
gcc (xPack GCC x86_64) {{ page.version }}
```

{% endcapture %}

{% capture linux %}

{{ easy_install }}

### Test

To check if the xpm installed GCC starts, use something like:

```console
$ ~/.local/xPacks/@xpack-dev-tools/gcc/{{ page.version }}-{{ page.xpack-subversion }}.1/.content/bin/gcc --version
gcc version {{ page.version }} (xPack GCC x86_64)
```

{{ manual_install }}

### Download

The GNU/Linux versions of **xPack GNU Compiler Collection**
are packed as `.tar.gz` archives.
Download the latest version named like:

- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-linux-x64.tar.gz`
- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-linux-arm.tar.gz`
- `xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-linux-arm64.tar.gz`

As the name implies, these are GNU/Linux `tar.gz` archives; they were build on
Ubuntu, but can be executed on most recent GNU/Linux distributions.

### Unpack

To manually install the xPack GNU Compiler Collection,
unpack the archive and copy it to
`${HOME}/.local/xPacks/gcc/xpack-gcc-<version>`:

```sh
mkdir -p ~/.local/xPacks/gcc
cd ~/.local/xPacks/gcc

tar xvf ~/Downloads/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}-linux-x64.tar.gz
chmod -R -w xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
```

You may shorten the last folder name and keep only the version.

{% include note.html content="For manual installs, the recommended
install location is slightly different from the xpm install folders,
which use the scope (like `@xpack-dev-tools`) to group different tools,
and `.content` to store the unpacked archive." %}

The result is a structure like:

```console
$ tree -L 2 /home/ilg/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
/home/ilg/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}
── bin
│   ├── addr2line
│   ├── ar
│   ├── as
│   ├── c++
│   ├── c++filt
│   ├── cpp
│   ├── dwp
│   ├── elfedit
│   ├── g++
│   ├── gcc
│   ├── gcc-ar
│   ├── gcc-nm
│   ├── gcc-ranlib
│   ├── gcore
│   ├── gcov
│   ├── gcov-dump
│   ├── gcov-tool
│   ├── gdb
│   ├── gdb-add-index
│   ├── gprof
│   ├── ld
│   ├── ld.bfd
│   ├── ld.gold
│   ├── lto-dump
│   ├── nm
│   ├── objcopy
│   ├── objdump
│   ├── ranlib
│   ├── readelf
│   ├── size
│   ├── strings
│   ├── strip
│   ├── x86_64-pc-linux-gnu-c++
│   ├── x86_64-pc-linux-gnu-g++
│   ├── x86_64-pc-linux-gnu-gcc
│   ├── x86_64-pc-linux-gnu-gcc-{{ page.version }}
│   ├── x86_64-pc-linux-gnu-gcc-ar
│   ├── x86_64-pc-linux-gnu-gcc-nm
│   └── x86_64-pc-linux-gnu-gcc-ranlib
├── distro-info
│   ├── CHANGELOG.md
│   ├── licenses
│   ├── patches
│   └── scripts
├── include
│   ├── ansidecl.h
│   ├── bfd.h
│   ├── bfdlink.h
│   ├── c++
│   ├── ctf-api.h
│   ├── ctf.h
│   ├── diagnostics.h
│   ├── dis-asm.h
│   ├── gdb
│   ├── plugin-api.h
│   └── symcat.h
├── lib
│   ├── bfd-plugins
│   ├── gcc
│   ├── libbfd.a
│   ├── libbfd.la
│   ├── libctf.a
│   ├── libctf.la
│   ├── libctf-nobfd.a
│   ├── libctf-nobfd.la
│   ├── libopcodes.a
│   └── libopcodes.la
├── lib64
│   ├── libasan.a
│   ├── libasan.la
│   ├── libasan_preinit.o
│   ├── libasan.so -> libasan.so.8.0.0
│   ├── libasan.so.8 -> libasan.so.8.0.0
│   ├── libasan.so.8.0.0
│   ├── libatomic.a
│   ├── libatomic.la
│   ├── libatomic.so -> libatomic.so.1.2.0
│   ├── libatomic.so.1 -> libatomic.so.1.2.0
│   ├── libatomic.so.1.2.0
│   ├── libcc1.a
│   ├── libcc1.la
│   ├── libcc1.so -> libcc1.so.0.0.0
│   ├── libcc1.so.0 -> libcc1.so.0.0.0
│   ├── libcc1.so.0.0.0
│   ├── libgcc_s.so
│   ├── libgcc_s.so.1
│   ├── libgomp.a
│   ├── libgomp.la
│   ├── libgomp.so -> libgomp.so.1.0.0
│   ├── libgomp.so.1 -> libgomp.so.1.0.0
│   ├── libgomp.so.1.0.0
│   ├── libgomp.spec
│   ├── libitm.a
│   ├── libitm.la
│   ├── libitm.so -> libitm.so.1.0.0
│   ├── libitm.so.1 -> libitm.so.1.0.0
│   ├── libitm.so.1.0.0
│   ├── libitm.spec
│   ├── liblsan.a
│   ├── liblsan.la
│   ├── liblsan_preinit.o
│   ├── liblsan.so -> liblsan.so.0.0.0
│   ├── liblsan.so.0 -> liblsan.so.0.0.0
│   ├── liblsan.so.0.0.0
│   ├── libquadmath.a
│   ├── libquadmath.la
│   ├── libquadmath.so -> libquadmath.so.0.0.0
│   ├── libquadmath.so.0 -> libquadmath.so.0.0.0
│   ├── libquadmath.so.0.0.0
│   ├── libsanitizer.spec
│   ├── libssp.a
│   ├── libssp.la
│   ├── libssp_nonshared.a
│   ├── libssp_nonshared.la
│   ├── libssp.so -> libssp.so.0.0.0
│   ├── libssp.so.0 -> libssp.so.0.0.0
│   ├── libssp.so.0.0.0
│   ├── libstdc++.a
│   ├── libstdc++fs.a
│   ├── libstdc++fs.la
│   ├── libstdc++.la
│   ├── libstdc++.so -> libstdc++.so.6.0.30
│   ├── libstdc++.so.6 -> libstdc++.so.6.0.30
│   ├── libstdc++.so.6.0.30
│   ├── libstdc++.so.6.0.30-gdb.py
│   ├── libsupc++.a
│   ├── libsupc++.la
│   ├── libtsan.a
│   ├── libtsan.la
│   ├── libtsan_preinit.o
│   ├── libtsan.so -> libtsan.so.2.0.0
│   ├── libtsan.so.2 -> libtsan.so.2.0.0
│   ├── libtsan.so.2.0.0
│   ├── libubsan.a
│   ├── libubsan.la
│   ├── libubsan.so -> libubsan.so.1.0.0
│   ├── libubsan.so.1 -> libubsan.so.1.0.0
│   └── libubsan.so.1.0.0
├── libexec
│   ├── gcc
│   ├── libexpat.so.1 -> libexpat.so.1.8.8
│   ├── libexpat.so.1.8.8
│   ├── libfl.so.2 -> libfl.so.2.0.0
│   ├── libfl.so.2.0.0
│   ├── libgcc_s.so.1
│   ├── libgmp.so.10 -> libgmp.so.10.4.1
│   ├── libgmp.so.10.4.1
│   ├── libisl.so.23 -> libisl.so.23.1.0
│   ├── libisl.so.23.1.0
│   ├── liblzma.so.5 -> liblzma.so.5.2.5
│   ├── liblzma.so.5.2.5
│   ├── libmpc.so.3 -> libmpc.so.3.2.1
│   ├── libmpc.so.3.2.1
│   ├── libmpfr.so.6 -> libmpfr.so.6.1.0
│   ├── libmpfr.so.6.1.0
│   ├── libncursesw.so.6 -> libncursesw.so.6.3
│   ├── libncursesw.so.6.3
│   ├── libstdc++.so.6 -> libstdc++.so.6.0.30
│   └── libstdc++.so.6.0.30
├── README.md
├── share
│   ├── doc
│   ├── gcc-{{ page.version }}
│   └── gdb
└── x86_64-pc-linux-gnu
    ├── bin
    └── lib

21 directories, 147 files
```

### Test

To check if the manually installed GCC starts, use something like:

```console
$ ~/.local/xPacks/gcc/xpack-gcc-{{ page.version }}-{{ page.xpack-subversion }}/bin/gcc --version
gcc version {{ page.version }} (xPack GCC x86_64)
```

{% endcapture %}

{% include platform-tabs.html %}

{% include warning.html content="**DO NOT** add the path to
the user or system path!" %}
