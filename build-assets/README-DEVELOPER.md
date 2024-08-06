# Developer info

## Static libraries on RedHat & SUSE

RedHat & SUSE require explicit install of static libraries, they
do not come with the common development packages.

```
docker run -it redhat/ubi8
docker run -it fedora:37

yum update --assumeyes
yum install --assumeyes git curl tar gzip redhat-lsb-core binutils which
yum install --assumeyes gcc-c++ gcc-c++ glibc glibc-common glibc-static libstdc++ libstdc++-static libatomic libgfortran
yum install --assumeyes libgcc*i686 libstdc++*i686 glibc*i686 libatomic*i686 libgfortran*i686

docker run -it opensuse/leap:15.4

zypper --no-gpg-checks update --no-confirm
zypper --no-gpg-checks install --no-confirm git-core curl tar gzip lsb-release binutils findutils util-linux
zypper --no-gpg-checks install --no-confirm gcc-c++ glibc glibc-devel-static
zypper --no-gpg-checks install --no-confirm gcc-32bit gcc-c++-32bit glibc-devel-32bit glibc-devel-static-32bit

find / -name 'libstdc++*'

cat <<__EOF__ >hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
std::cout << "Hello" << std::endl;

return 0;
}
__EOF__


g++ hello.cpp -o hello -v
ldd -v hello

g++ hello.cpp -o sl-hello -static-libstdc++ -static-libgcc -v -Wl,-v,-t
ldd -v sl-hello

g++ hello.cpp -o s-hello -static -v -Wl,-v,-t
ldd -v s-hello


g++ hello.cpp -o hello-32 -v -m32
ldd -v hello-32

g++ hello.cpp -o sl-hello-32 -static-libstdc++ -static-libgcc -v -Wl,-v,-t -m32
ldd -v sl-hello-32

g++ hello.cpp -o s-hello-32 -static -v -Wl,-v,-t -m32
ldd -v s-hello-32
```

## Buggy Apple linker in macos-14

The default Xcode that comes with macos-14 is buggy:

```console
[/Users/runner/work/gcc-xpack/gcc-xpack/build/darwin-arm64/aarch64-apple-darwin23.5.0/tests/gcc-xpack/xpacks/.bin/g++ simple-exception.cpp -o simple-exception]
0  0x102c7b648  __assert_rtn + 72
1  0x102baffac  ld::AtomPlacement::findAtom(unsigned char, unsigned long long, ld::AtomPlacement::AtomLoc const*&, long long&) const + 1204
2  0x102bc5924  ld::InputFiles::SliceParser::parseObjectFile(mach_o::Header const*) const + 15164
3  0x102bd2e30  ld::InputFiles::parseAllFiles(void (ld::AtomFile const*) block_pointer)::$_7::operator()(unsigned long, ld::FileInfo const&) const + 420
4  0x19c4b6428  _dispatch_client_callout2 + 20
5  0x19c4ca850  _dispatch_apply_invoke3 + 336
6  0x19c4b63e8  _dispatch_client_callout + 20
7  0x19c4b7c68  _dispatch_once_callout + 32
8  0x19c4caeec  _dispatch_apply_invoke_and_wait + 372
9  0x19c4c9e9c  _dispatch_apply_with_attr_f + 1212
10  0x19c4ca08c  dispatch_apply + 96
11  0x102c4d3b8  ld::AtomFileConsolidator::parseFiles(bool) + 292
12  0x102bee170  main + 9048
ld: Assertion failed: (resultIndex < sectData.atoms.size()), function findAtom, file Relocations.cpp, line 1336.
collect2: error: ld returned 1 exit status
```

The solution is to switch to a newer one:

```sh
sudo xcode-select --switch /Applications/Xcode_15.4.app
```

- <https://github.com/actions/runner-images/blob/main/images/macos/macos-14-Readme.md>
