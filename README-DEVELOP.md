TODO

```sh
bash ${HOME}/Work/gcc-xpack.git/scripts/helper/build-native.sh --develop --without-pdf
bash ${HOME}/Work/gcc-xpack.git/scripts/helper/build-native.sh --develop  --without-pdf --win

```

## Patches

A good source of patches for Windows is
[MSYS2](https://github.com/msys2/MINGW-packages/tree/master/mingw-w64-gcc).

In the `forks/gcc.git` repo:

- select tag like `releases/gcc-11.3.0`
- checkout
- create new branch `gcc-11.3.0-xpack`
- select the commits from the previous release
- cherry pick
- if empty, it was already applied
