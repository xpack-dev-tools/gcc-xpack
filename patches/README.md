# Patches

In reverse chronological order.

## gcc-12.1.0

- the HomeBrew
  [gcc@12](https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@12.rb)
  patch [a000f1d9](https://raw.githubusercontent.com/Homebrew/formula-patches/76677f2b/gcc/gcc-12.1.0-arm.diff)
  using <https://github.com/iains/gcc-12-branch/tree/gcc-12.1-darwin-r1>

## gcc-11.2.0

- the 11.1.0 patches were already applied

## gcc-11.1.0

From the 10.3.0 pathes only the following are still needed:

- 7c603542 - Change EH pointer encodings to PC relative on Windows (0204)
- ee391a34 - Fix PR target/100402 (0203-backport-longjmp-fix.patch)

## gcc-10.3.0

Multiple patches from MSYS2.

## gcc-8.5.0

Fix the darwin driver to make it recognise macOS 11.
