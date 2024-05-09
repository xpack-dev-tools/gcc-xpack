# Patches

Homebrew patches for gcc:

- <https://github.com/Homebrew/formula-patches/tree/master/gcc>

To get them, use the exact URL from the `gcc.rb` file:

```sh
curl -L "https://raw.githubusercontent.com/Homebrew/formula-patches/.../gcc/gcc-X.Y.0.diff" -o gcc-X.Y.0-darwin.git.patch
```

In reverse chronological order.

## gcc 14.1

- the HomeBrew
  [gcc](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb)
  url "https://raw.githubusercontent.com/Homebrew/formula-patches/82b5c1cd38826ab67ac7fc498a8fe74376a40f4a/gcc/gcc-14.1.0.diff"
  using <https://github.com/iains/gcc-14-branch>

## gcc 13.2

- the HomeBrew
  [gcc](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb)
  url "https://raw.githubusercontent.com/Homebrew/formula-patches/3c5cbc8e9cf444a1967786af48e430588e1eb481/gcc/gcc-13.2.0.diff"
  using <https://github.com/iains/gcc-13-branch>

## gcc 13.1

- the HomeBrew
  [gcc](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb)
  url "https://raw.githubusercontent.com/Homebrew/formula-patches/master/gcc/gcc-13.1.0.diff"
  using <https://github.com/iains/gcc-13-branch>

## gcc-12.2.0

- the HomeBrew
  [gcc](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb)
  patch [a000f1d9](https://raw.githubusercontent.com/Homebrew/formula-patches/1d184289/gcc/gcc-12.2.0-arm.diff)
  using <https://github.com/iains/gcc-12-branch/tree/gcc-12-2-darwin>

## gcc-12.1.0

- the HomeBrew
  [gcc](https://github.com/Homebrew/homebrew-core/blob/master/Formula/g/gcc.rb)
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
