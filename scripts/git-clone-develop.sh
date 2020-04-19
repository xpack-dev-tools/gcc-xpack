#!/usr/bin/env bash
rm -rf "${HOME}/Downloads/gcc-xpack.git"
git clone \
  --recurse-submodules \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/gcc-xpack.git \
  "${HOME}/Downloads/gcc-xpack.git"
