# Change & release log

Entries in this file are in reverse chronological order.

## 2024-05-30

* 5bac3c0 re-generate workflows
* 69543b0 README update
* b369f69 versioning.sh: build only 64-bit bootstrap

## 2024-05-29

* 47d901d versioning.sh: cleanups
* cb78deb README update
* 0ce5271 versioning.sh: add --bootstrap
* e24fb88 package.json: bump deps
* 1038c90 versioning.sh: try mingw 12
* 68e7e13 versioning.sh: try zstd 1.5.6

## 2024-05-23

* aeaa2ea package.json: clang 16.0.6-1.1

## 2024-05-22

* ac22264 versioning.sh: add link to gcc@13.rb
* 2976eae add gcc-13.3.0-darwin.git.patch
* fd2022c versioning.sh: cosmetics
* 201d633 application.sh: cleanups
* 1143398 application.sh: dismiss ENABLE_LINK_VERBOSE
* 3a0a421 application.sh: add ENABLE_LINK_VERBOSE
* 5a4e006 application.sh: add SKIP_MACOS_TOOLCHAIN_LIBRARY_PATHS
* dee828d remove local common patches

## 2024-05-20

* 3f39d71 package.json: remove gcc from darwin

## 2024-05-19

* 03e682d versioning.sh: unify -cross.git.patch

## 2024-05-18

* 6587e3a package.json: XBB_ENVIRONMENT_SKIP_CHECKS

## 2024-05-17

* 880e54b package.json: --env XBB_ENVIRONMENT_SKIP_CHECKS
* 89aba6d README update

## 2024-05-16

* fb34439 application.sh: WIN32_WINNT="0x0601"
* f2bf22a READMEs update
* b27eeaf application.sh: no need for USE_GCC_FOR_GCC_ON_MACOS

## 2024-05-14

* 493c27e versioning.sh: link to gcov bug

## 2024-05-09

* 3f126cb README update
* 4b41371 README update
* 90bfd6d add gcc-14.1.0-darwin.git.patch

## 2024-05-08

* 57db496 USE_GCC_FOR_GCC_ON_MACOS="y"
* 611a239 package.json: add gcc for macOS

## 2024-05-07

* 6809225 application.sh: 14.1 no longer pre-release
* d435b93 VERSION 14.1.0
* 4ef480b versioning.sh: compute GCC minor
* a56382b versioning.sh: generic pre-release branch

## 2024-05-03

* 870e12f versioning.sh: use gcc-14 branch on linux

## 2024-05-02

* e373258 package.json: clang 17.0.6-1.1
* 47df998 versioning.sh: update 14.1 git url
* 975596d versioning.sh: use latest git commits

## 2024-04-26

* 4e57df8 application.sh: dependencies update
* 182f907 versioning.sh: move to git head
* af67a94 application.sh: add XBB_APPLICATION_SKIP_MACOSX_DEPLOYMENT_TARGET

## 2024-04-23

* 07a8266 versioning.sh: separate intel/arm for macOS
* e5f755b versioning.sh: try Apr 20
* 1870174 versioning.sh: cleanup bisect
* 39e01bc README update
* f43e792 versioning.sh: XBB_GCC_GIT_COMMIT (bisect)

## 2024-04-22

* e9a38e7 versioning.sh: cosmetics

## 2024-04-21

* 7677c57 versioning.sh: skip bootstrap tests sometimes

## 2024-04-19

* f397c9d application.sh: disable gcc check
* c171d35 README update
* 990d053 versioning.sh: gmp_build before guile_build
* 12974f9 add libtool_build
* 06608fc versioning.sh: add gcc tests prerequisites
* 019d715 application.sh: add _ENABLE_GCC_CHECK

## 2024-04-18

* ac0d6b0 versioning.sh: rework static libiconv

## 2024-04-17

* 233742e package.json: xbb-v5.2.1
* fa516f0 versioning.sh: rework static libiconv
* 695c774 package.json: revert to clang 16
* 6ac7d54 package.json: use clang 17
* e7e477c versioning.sh: explicit arm64 branch
* 304f38b versioning.sj: XBB_GCC_GIT
* 0da84be application.sh: comment out HAS_LIBZ1DYLIB

## 2024-04-15

* 1c91271 versioning.sh: remove APP_SRC_FOLDER_NAME
* ecdc6be versioning.sh: fix syntax
* aaa1e4a versioning.sh: include windows in pre-release test
* 02e50d4 versioning.sh: bump commit

## 2024-04-14

* 2cca931 versioning.sh: fix linux urls

## 2024-04-13

* 0181aa5 versioning.sh: add git urls for linux
* 77fee3f package.json 14.0.1
* 074628e VERSION 14.0.1
* dca3283 versioning.sh: add git url for 13.3
* 2df5c21 versioning.sh: add static libiconv
* bdfadee application.sh: XBB_APPLICATION_TEST_PRERELEASE

## 2024-04-11

* 43fec5f README update
* e1941d7 versioning.sh: add support for 14.*
* 8c9db00 application.sh: add commented out defs

## 2024-04-10

* 72fece4 README update
* d5934b9 README update

## 2024-04-08

* 9ff424f package.json: bump deps
* 039cf24 versioning.sh: add xz warning message

## 2024-03-23

* f819841 README update

## 2024-03-22

* 0008128 package.json: xpm-version 0.18.0

## 2024-03-08

* 59ad47e package.json: xpm-version 0.18.0

## 2024-03-07

* f2031a1 package.json: xpm-version 0.18.0
* d15c579 README update
* d80cf6f package.json: bump deps

## 2024-02-24

* c16f855 README update
* 443f89d 13.2.0-2.1
* 0a07896 CHANGELOG: publish npm v13.2.0-2.1
* 66137ea package.json: update urls for 13.2.0-2.1 release
* a0fc7cc CHANGELOG update
* 357c83f prepare v13.2.0-2
* 911cca8 12.3.0-2.1
* 4957643 CHANGELOG: publish npm v12.3.0-2.1
* c2728f7 package.json: update urls for 12.3.0-2.1 release
* 0e23869 CHANGELOG update* 33dd444 README update
* 535957f prepare v12.3.0-2

## 2024-02-23

* 553d950 11.4.0-2.1
* 6d276dd CHANGELOG: publish npm v11.4.0-2.
* a587438 package.json: update urls for 11.4.0-2.1 release
* faff146 CHANGELOG update
* c46756d jekyll-release update deprecation
* f4bf907 jekyll-release update deprecation
* 6619f1f workflows: use v1.13.0
* af1a11b build-xbbma.yml: use v1.13.0
* c1b7d78 build-xbbli.yml: try 1.13.0
* 878357b add NOTES.md
* 5c7a1a4 README update
* 5ced8f6 prepare v11.4.0-2

## 2024-02-07

* 4859ea2 READMEs update

## 2023-12-05

* bfbe3d4 README update
* bc27968 11.4.0-1.1
* dc25371 CHANGELOG: publish npm v11.4.0-1.1
* 652ffd4 package.json: update urls for 11.4.0-1.1 release
* c5b104f body-jekyll update
* 05b6aba CHANGELOG update
* 206e218 package.json: bump deps
* 9f32162 CHANGELOG update
* ad670ec package.json: bump deps
* 9490f76 CHANGELOG update
* e5d5622 re-generate workflows
* cde6b6b versioning.sh: deprecated as comments
* 8b3f1e3 README update
* 31b73bd prepare v11.4.0-1
* 2617c32 add gcc-11.4 patch

## 2023-12-04

* c652b93 versioning.sh update links to homebrew
* 8b3c42c package-lock.json update
* b9aa2a6 README update
* e207e4b versioning.sh: add support to try 11.4

## 2023-12-03

* 0377385 package.json: bump deps

## 2023-11-12

* 23500c1 package.json: bump deps

## 2023-09-25

* d4ce684 body-jekyll update

## 2023-09-20

* 1ef71c3 package.json: bump deps

## 2023-09-16

* 0aad7c0 package.json: add linux32
* b00b7b4 body-jekyll update

## 2023-09-11

* 649d80e package.json: bump deps

## 2023-09-08

* 99f72e7 package.json: bump deps

## 2023-09-06

* 6046afc package.json: bump deps
* 22f0ddb READMEs update
* 1ac0c45 body-jekyll update

## 2023-09-05

* 4572ee6 READMEs update
* 9ba5e17 package.json: bump deps

## 2023-09-03

* 02541bd package.json: bump deps

## 2023-08-31

* 8eecd90 13.2.0-1.1
* a03e962 CHANGELOG: publish npm v13.2.0-1.1
* ad7e487 package.json: update urls for 13.2.0-1.1 release
* 8fb2913 README update
* fcac97a package.json: update bins
* 46fcbe1 CHANGELOG update
* a4ff6aa templates/jekyll update
* 6fccf60 README update durations
* 472b489 README update durations
* 3971c11 prepare v13.2.0-1
* 06390a2 12.3.0-1.1
* 132de7e CHANGELOG: publish npm v12.3.0-1.1
* a88af78 package.json: update urls for 12.3.0-1.1 release
* 025c230 README update
* a423242 templates/jekyll update
* 7cba640 CHANGELOG update
* 73ebb22 tests/update.sh: disable 32-bit tests RedHat & Co
* cf8ef05 README update durations
* c411190 Revert "remove tests/update.sh"
* 1ca0b94 package.json: bump deps
* 44dc3e5 CHANGELOG update
* 6081818 package.json: bump deps

## 2023-08-30

* c3e3504 README add build release
* f38744e package.json: bump deps
* 2f405a2 package.json: bump deps
* 2f3f348 package.json: bump deps
* 6a420c3 CHANGELOG update
* 8dc0fb3 package.json: bump deps
* dad3083 CHANGELOG update
* c4703e0 package.json: bump deps
* 70226a4 README update
* c1c11be prepare v12.3.0-1
* 8097fc6 prepare v12.3.0-1

## 2023-08-29

* 564d356 application.sh: add XBB_APPLICATION_HAS_FLEX_PACKAGE="y"
* 4ad57a6 versioning.sh: remove explicit set_flex_package_paths
* cecdb29 .vscode/settings.json: ignoreWords
* 1759926 gcc-12.3.0.git.patch moved to helper
* 7257b7e versioning.sh: xbb_set_flex_package_paths
* c37822b package.json: add bison & flex

## 2023-08-28

* bd45498 README updates

## 2023-08-27

* e672e9c gcc-12.3.0-darwin.git.patch rename
* 3235cf4 gcc-13.2.0-darwin.git.diff update from brew
* 3a694fd add gcc-13.2.0-darwin.git.patch
* d5f26a9 13.2.0-1
* f1cb3f5 README update
* 3d44723 add gcc-12.3.0.git.patch
* ed1875e add XBB_APPLICATION_BOOTSTRAP_ONLY
* e70b713 versioning.sh: mention gcc-*-darwin.git.patch
* c647045 versioning.sh: reorder i686 x86_64

## 2023-08-25

* 76f5883 versioning.sh: add 13.2 same as 12.3
* 2d35156 versioning.sh: fix syntax
* 03373d9 package.json: 12.3.0-1.1.pre
* f87420e dot.*ignore update
* b136880 re-generate workflows
* ca65d39 versioning.sh: add 12.3 versions
* d48a0c4 package.json: rm xpack-dev-tools-build/*
* 392f43f remove tests/update.sh
* 1884d2f package.json: bump deps

## 2023-08-21

* 95eaa36 READMEs update
* 1abee41 package.json: bump deps

## 2023-08-19

* dab516d READMEs update
* 5550dd0 package.json: bump deps

## 2023-08-15

* 94a26ee re-generate workflows
* 5eea611 README-MAINTAINER rename xbbla
* 32c7942 package.json: rename xbbla
* d22e372 package.json: bump deps
* 50e8e4d READMEs update
* 1746e1e package.json: bump deps

## 2023-08-05

* 7c6fc59 READMEs update

## 2023-08-04

* 0fd5747 READMEs update
* 2b9a3e0 READMEs update
* 1bffb4d package.json: add build-develop-debug
* 6990c74 READMEs update

## 2023-08-03

* ef43187 package.json: reorder build actions
* e32cec1 READMEs update
* 1829bb1 package.json: bump deps

## 2023-07-29

* d463f64 README update
* a5965be versioning.sh: use generic 12.*
* 8832f82 rename gcc-11.4.0-darwin.git.patch

## 2023-07-28

* e25e547 prepare v12.3.0-1
* aac05e0 patches: add 11.4.0, 12.3.0, 13.1.0
* f0d4b86 READMEs update
* 3620f16 package.json: bump deps
* 2bafd70 package.json: liquidjs --context --template
* 17282c6 scripts cosmetics
* 66cd09a re-generate workflows
* 6d6486a READMEs update
* 267cb96 package.json: minXpm 0.16.3 & @xpack-dev-tools/xbb-helper
* d73664d READMEs update
* a7b9840 package.json: bump deps

## 2023-07-26

* 9cd761b versioning.sh: cosmetics
* 38ab526 package.json: move scripts to actions
* 3cee766 package.json: update xpack-dev-tools path
* ccc6195 READMEs update xpack-dev-tools path
* 8e36fa3 body-jekyll update
* 42026a7 READMEs update

## 2023-07-17

* 2757542 package.json: bump deps

## 2023-03-25

* d7c48c2 READMEs update

## 2022-12-30

* a9f4f03 README-MAINTAINER: xpm run install
* 4ab9913 versioning.sh: disable zstd

## 2022-12-29

* v12.2.0-3 prepared

## 2022-12-27

* v12.2.0-2.1 published on npmjs.com
* v12.2.0-2 released
* update for XBB v5.0.0

## 2022-11-14

* v12.2.0-2 prepared

## 2022-08-30

* v12.2.0-1.1 published on npmjs.com
* v12.2.0-1 released

## 2022-08-20

* v12.2.0-1 prepared

## 2022-06-16

* v12.1.0-1.1 published on npmjs.com
* v12.1.0-1 released
* v12.1.0-1 prepared
* update patch for gcc-12.1-darwin-r1

## 2022-06-01

* add HomeBrew 12.1 patch for Apple Silicon
* v12.1.0-1 prepared

## 2022-05-31

* v11.3.0-1.1 published on npmjs.com
* v11.3.0-1 released
* add HomeBrew 11.3 patch for Apple Silicon

## 2022-05-12

* v12.1.0-1 prepared

## 2022-04-21

* v11.3.0-1 prepared

## 2022-02-11

* v11.2.0-3.3 published on npmjs.com
* v11.2.0-3 released

## 2022-02-10

* v11.2.0-3 prepared
* bump binutils to 2.38
* update to latest helper

## 2021-11-25

* v11.2.0-2 prepared (with support for Apple Silicon)

## 2021-11-22

* v11.1.0-1 prepared (the only that currently works on Apple Silicon)
* update download url for Apple Silicon

## 2021-10-20

* v11.2.0-1.3 published on npmjs.com
* add widl & co to xpack/bin
* v11.2.0-1.2 published on npmjs.com
* add gdb to xpack/bin
* v11.2.0-1.1 published on npmjs.com
* v11.2.0-1 released

## 2021-05-24

* v8.5.0-1.1 published on npmjs.com
* v8.5.0-1 released
* remove gcc-ar/nm/ranlib on macOS
* rework/unify build & CI tests

## 2021-05-21

* v8.5.0-1 prepared
* enable support for Fortran & Obj-C/C++

## 2021-05-17

* v8.5.0-1 prepared
