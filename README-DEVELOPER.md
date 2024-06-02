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
