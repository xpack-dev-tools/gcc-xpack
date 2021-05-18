# How to make a new release (maintainer info)

## Release schedule

The xPack GCC release schedule generally follows the original GNU
[releases](https://gcc.gnu.org/releases.html), but with a
several weeks filter, which means that releases that are shortly
overwritten are skipped. Also initial x.y.0 releases are skipped.

## Prepare the build

Before starting the build, perform some checks and tweaks.

### Check Git

- switch to the `xpack-develop` branch
- if needed, merge the `xpack` branch

### Increase the version

Determine the version (like `8.5.0`) and update the `scripts/VERSION`
file; the format is `8.5.0-1`. The fourth number is the xPack release number
of this version. A fifth number will be added when publishing
the package on the `npm` server.

### Fix possible open issues

Check GitHub issues and pull requests:

- <https://github.com/xpack-dev-tools/gcc-xpack/issues/>

and fix them; assign them to a milestone (like `8.5.0-1`).

### Check `README.md`

Normally `README.md` should not need changes, but better check.
Information related to the new version should not be included here,
but in the version specific file (below).

- update version in README-RELEASE.md
- update version in README-BUILD.md

## Update `CHANGELOG.md`

- open the `CHANGELOG.md` file
- check if all previous fixed issues are in
- add a new entry like _v8.5.0-1 prepared_
- commit with a message like _prepare v8.5.0-1_

Note: if you missed to update the `CHANGELOG.md` before starting the build,
edit the file and rerun the build, it should take only a few minutes to
recreate the archives with the correct file.

### Update the version specific code

- open the `common-versions-source.sh` file
- add a new `if` with the new version before the existing code

### Update helper

With Sourcetree, go to the helper repo and update to the latest master commit.

## Build

### Development run the build scripts

Before the real build, run a test build on the development machine (`wks`):

```sh
sudo rm -rf ~/Work/gcc-*

caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --develop --without-pdf --without-html --disable-tests --all

caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --develop --without-pdf --without-html --disable-tests --osx

caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --develop --without-pdf --without-html --disable-tests --linux64 --win64

caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --develop --without-pdf --without-html --disable-tests --linux32 --win32
```

Work on the scripts until all 4 platforms pass the build.

## Push the build script

In this Git repo:

- push the `xpack-develop` branch to GitHub
- possibly push the helper project too

From here it'll be cloned on the production machines.

### Run the build scripts

On the macOS machine (`xbbm`) open ssh sessions to both Linux machines
(`xbbi` and `xbba`):

```sh
caffeinate ssh xbbi

caffeinate ssh xbba
```

On all machines, clone the `xpack-develop` branch:

```sh
rm -rf ~/Downloads/gcc-xpack.git
git clone \
  --recurse-submodules \
  --branch xpack-develop \
  https://github.com/xpack-dev-tools/gcc-xpack.git \
  ~/Downloads/gcc-xpack.git
```

On all machines, remove any previous build:

```sh
sudo rm -rf ~/Work/gcc-*
```

Empty trash.

On the macOS machine (`xbbm`):

```sh
caffeinate bash ~/Downloads/gcc-xpack.git/scripts/build.sh --osx
```

A typical run takes about 30 minutes.

On `xbbi`:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all

bash ~/Downloads/gcc-xpack.git/scripts/build.sh --linux64 --win64
bash ~/Downloads/gcc-xpack.git/scripts/build.sh --linux32 --win32
```

A typical run on the Intel machine takes about 40 minutes.

On `xbba`:

```sh
bash ~/Downloads/gcc-xpack.git/scripts/build.sh --all

bash ~/Downloads/gcc-xpack.git/scripts/build.sh --arm64
bash ~/Downloads/gcc-xpack.git/scripts/build.sh --arm32
```

A typical run on the Arm machine takes about 95 minutes.

### Clean the destination folder

On the development machine (`wks`) clear the folder where binaries from all
build machines will be collected.

```sh
rm -f ~/Downloads/xpack-binaries/gcc/*
```

### Copy the binaries to the development machine

On all three machines:

```sh
(cd ~/Work/gcc-*/deploy; scp * ilg@wks:Downloads/xpack-binaries/gcc)
```

## Testing

Install the binaries on all supported platforms and check if they are
functional.

## Create a new GitHub pre-release

- in `CHANGELOG.md`, add release date
- commit and push the `xpack-develop` branch
- go to the GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases/) page
- click **Draft a new release**, in the `xpack-develop` branch
- name the tag like **v8.5.0-1** (mind the dash in the middle!)
- name the release like **xPack GCC v8.5.0-1**
(mind the dash)
- as description, use:

```console
![Github Releases (by Release)](https://img.shields.io/github/downloads/xpack-dev-tools/gcc-xpack/v8.5.0-1/total.svg)

Version v8.5.0-1 is a new release of the **xPack GCC** package, following the GCC release.

_For the moment these binaries are provided only for testing purposes!_
```

- **attach binaries** and SHA (drag and drop from the archives folder will do it)
- **enable** the **pre-release** button
- click the **Publish Release** button

Note: at this moment the system should send a notification to all clients
watching this project.

## Run the release Travis tests

Using the scripts in `tests/scripts/`, start:

- `trigger-travis-quick.mac.command` (optional)
- `trigger-travis-stable.mac.command`
- `trigger-travis-latest.mac.command`

The test results are available from:

- <https://travis-ci.com/github/xpack-dev-tools/gcc-xpack>

For more details, see `tests/scripts/README.md`.

## Prepare a new blog post

In the `xpack/web-jekyll` GitHub repo:

- select the `develop` branch
- add a new file to `_posts/gcc/releases`
- name the file like `2021-05-17-gcc-v8-5-0-1-released.md`
- name the post like: **xPack GCC v8.5.0-1 released**
- as `download_url` use the tagged URL like `https://github.com/xpack-dev-tools/gcc-xpack/releases/tag/v8.5.0-1/`
- update the `date:` field with the current date
- update the Travis URLs using the actual test pages
- update the SHA sums via copy/paste from the original build machines
(it is very important to use the originals!)

If any, refer to closed
[issues](https://github.com/xpack-dev-tools/gcc-xpack/issues)
as:

- **[Issue:\[#1\]\(...\)]**.

### Update the SHA sums

On the development machine (`wks`):

```sh
cat ~/Downloads/xpack-binaries/gcc/*.sha
```

Copy/paste the build report at the end of the post as:

```console
## Checksums
The SHA-256 hashes for the files are:

0a2a2550ec99b908c92811f8dbfde200956a22ab3d9af1c92ce9926bf8feddf9
xpack-gcc-8.5.0-1-darwin-x64.tar.gz

254588cbcd685748598dd7bbfaf89280ab719bfcd4dabeb0269fdb97a52b9d7a
xpack-gcc-8.5.0-1-linux-arm.tar.gz

10e30128d626f9640c0d585e6b65ac943de59fbdce5550386add015bcce408fa
xpack-gcc-8.5.0-1-linux-arm64.tar.gz

50f2e399382c29f8cdc9c77948e1382dfd5db20c2cb25c5980cb29774962483f
xpack-gcc-8.5.0-1-linux-ia32.tar.gz

9b147443780b7f825eec333857ac7ff9e9e9151fd17c8b7ce2a1ecb6e3767fd6
xpack-gcc-8.5.0-1-linux-x64.tar.gz

501366492cd73b06fca98b8283f65b53833622995c6e44760eda8f4483648525
xpack-gcc-8.5.0-1-win32-ia32.zip

dffc858d64be5539410aa6d3f3515c6de751cd295c99217091f5ccec79cabf39
xpack-gcc-8.5.0-1-win32-x64.zip
```

## Update the preview Web

- commit the `develop` branch of `xpack/web-jekyll` GitHub repo;
  use a message like **xPack GCC v8.5.0-1 released**
- wait for the GitHub Pages build to complete
- the preview web is <https://xpack.github.io/web-preview/>

## Update package.json binaries

- select the `xpack-develop` branch
- run `xpm-dev binaries-update`

```console
xpm-dev binaries-update -C "${HOME}/Downloads/gcc-xpack.git" '8.5.0-1' "${HOME}/Downloads/xpack-binaries/gcc"
```

- open the GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases)
  page and select the latest release
- check the download counter, it should match the number of tests
- open the `package.json` file
- check the `baseUrl:` it should match the file URLs (including the tag/version);
  no terminating `/` is required
- from the release, check the SHA & file names
- compare the SHA sums with those shown by `cat *.sha`
- check the executable names
- commit all changes, use a message like
  `package.json: update urls for 8.5.0-1.1 release` (without `v`)

## Publish on the npmjs.com server

- select the `xpack-develop` branch
- check the latest commits `npm run git-log`
- update `CHANGELOG.md`; commit with a message like
  _CHANGELOG: prepare npm v8.5.0-1.1_
- `npm pack` and check the content of the archive, which should list
  only the `package.json`, the `README.md`, `LICENSE` and `CHANGELOG.md`;
  possibly adjust `.npmignore`
- `npm version 8.5.0-1.1`; the first 5 numbers are the same as the
  GitHub release; the sixth number is the npm specific version
- push the `xpack-develop` branch to GitHub
- push tags with `git push origin --tags`
- `npm publish --tag next` (use `--access public` when publishing for
  the first time); for updates use `npm publish --tag update`

The version is visible at:

- <https://www.npmjs.com/package/@xpack-dev-tools/gcc?activeTab=versions>

## Test if the npm binaries can be installed with xpm

Run the `tests/scripts/trigger-travis-xpm-install.sh` script, this
will install the package on Intel Linux 64-bit, macOS and Windows 64-bit.

The test results are available from:

- <https://travis-ci.com/github/xpack-dev-tools/gcc-xpack>

For 32-bit Windows, 32-bit Intel GNU/Linux and 32-bit Arm, install manually.

```sh
xpm install --global @xpack-dev-tools/gcc@next
```

## Test the npm binaries

Install the binaries on all platforms.

```sh
xpm install --global @xpack-dev-tools/gcc@next
```

On GNU/Linux systems, including Raspberry Pi, use the following commands:

```sh
~/.local/xPacks/@xpack-dev-tools/gcc/8.5.0-1.1/.content/bin/gcc --version

gcc (xPack GCC 64-bit) 8.5.0
```

On macOS, use:

```sh
~/Library/xPacks/@xpack-dev-tools/gcc/8.5.0-1.1/.content/bin/gcc --version

gcc (xPack GCC 64-bit) 8.5.0
```

On Windows use:

```ps
%USERPROFILE%\AppData\Roaming\xPacks\@xpack-dev-tools\gcc\8.5.0-1.1\.content\bin\gcc --version

gcc.exe (xPack MinGW-w64 GCC 64-bit) 8.5.0
```

## Update the repo

- merge `xpack-develop` into `xpack`
- push

## Tag the npm package as `latest`

When the release is considered stable, promote it as `latest`:

- `npm dist-tag ls @xpack-dev-tools/gcc`
- `npm dist-tag add @xpack-dev-tools/gcc@8.5.0-1.1 latest`
- `npm dist-tag ls @xpack-dev-tools/gcc`

## Update the Web

- in the `master` branch, merge the `develop` branch
- wait for the GitHub Pages build to complete
- the result is in <https://xpack.github.io/news/>
- remember the post URL, since it must be updated in the release page

## Create the final GitHub release

- go to the GitHub [releases](https://github.com/xpack-dev-tools/gcc-xpack/releases) page
- check the download counter, it should match the number of tests
- add a link to the Web page `[Continue reading »]()`; use an same blog URL
- **disable** the **pre-release** button
- click the **Update Release** button

## Share on Twitter

- in a separate browser windows, open [TweetDeck](https://tweetdeck.twitter.com/)
- using the `@xpack_project` account
- paste the release name like **xPack GCC v8.5.0-1 released**
- paste the link to the Web page
  [release](https://xpack.github.io/gcc/releases/)
- click the **Tweet** button
