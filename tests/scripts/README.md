# Scripts to test the GCC xPack

The binaries can be available from one of the pre-releases:

https://github.com/xpack-dev-tools/pre-releases/releases

## Download the repo

The test script is part of the GCC xPack:

```sh
rm -rf ~/Downloads/gcc-xpack.git
git clone --recurse-submodules -b xpack-develop \
  https://github.com/xpack-dev-tools/gcc-xpack.git  \
  ~/Downloads/gcc-xpack.git
```

## Start a local test

To check if GCC starts on the current platform, run a native test:

```sh
bash ~/Downloads/gcc-xpack.git/tests/scripts/native-test.sh \
  "https://github.com/xpack-dev-tools/pre-releases/releases/download/experimental/"
```

The script stores the downloaded archive in a local cache, and
does not download it again if available locally.

To force a new download, remove the local archive:

```console
rm ~/Work/cache/xpack-gcc-*
```

## Start the Travis test

The multi-platform test runs on Travis CI; it is configured to not fire on
git actions, but only via a manual POST to the Travis API.

```sh
bash ~/Downloads/gcc-xpack.git/tests/scripts/travis-trigger.sh
```

For convenience, on macOS this can be invoked from Finder, using
the `travis-trigger.mac.command` shortcut.
