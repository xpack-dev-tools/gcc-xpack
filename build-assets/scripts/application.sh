# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Application specific definitions. Included with source.

# Used to display the application name in branding strings.
XBB_APPLICATION_NAME=${XBB_APPLICATION_NAME:-"GCC"}

# Used as part of file/folder paths.
XBB_APPLICATION_LOWER_CASE_NAME=${XBB_APPLICATION_LOWER_CASE_NAME:-"gcc"}

XBB_APPLICATION_DISTRO_NAME=${XBB_APPLICATION_DISTRO_NAME:-"xPack"}
XBB_APPLICATION_DISTRO_LOWER_CASE_NAME=${XBB_APPLICATION_DISTRO_LOWER_CASE_NAME:-"xpack"}
XBB_APPLICATION_DISTRO_TOP_FOLDER=${XBB_APPLICATION_DISTRO_TOP_FOLDER:-"xPacks"}

XBB_APPLICATION_DESCRIPTION="${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME}"

declare -a XBB_APPLICATION_DEPENDENCIES=( )
declare -a XBB_APPLICATION_COMMON_DEPENDENCIES=( libunistring libffi gc libtool guile autogen libiconv zlib gmp mpfr mpc isl zstd ncurses expat xz binutils gcc-mingw mingw gcc gdb )

XBB_APPLICATION_HAS_FLEX_PACKAGE="y"

# XBB_APPLICATION_BOOTSTRAP_ONLY="y"

# To download from the dedicated git branch instead of the released archive.
# XBB_APPLICATION_TEST_PRERELEASE="y"

# XBB_APPLICATION_ENABLE_GCC_CHECK="y"

# Skip using MACOSX_DEPLOYMENT_TARGET on the
# development machine which uses a very new CLT.
XBB_APPLICATION_SKIP_MACOSX_DEPLOYMENT_TARGET="y"

# Since the toolchain is used only in the bootstrap stage, on macOS
# the toolchain library path is added only to `--with-stage1-ldflags`.
XBB_APPLICATION_SKIP_MACOS_TOOLCHAIN_LIBRARY_PATHS="y"

# XBB_APPLICATION_USE_GCC_FOR_GCC_ON_MACOS="y"

# https://learn.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt
# Windows 7
XBB_APPLICATION_WIN32_WINNT="0x0601"

# -----------------------------------------------------------------------------

XBB_GITHUB_ORG="${XBB_GITHUB_ORG:-"xpack-dev-tools"}"
XBB_GITHUB_REPO="${XBB_GITHUB_REPO:-"${XBB_APPLICATION_LOWER_CASE_NAME}-xpack"}"
XBB_GITHUB_PRE_RELEASES="${XBB_GITHUB_PRE_RELEASES:-"pre-releases"}"

XBB_NPM_PACKAGE="${XBB_NPM_PACKAGE:-"@xpack-dev-tools/${XBB_APPLICATION_LOWER_CASE_NAME}@${XBB_NPM_PACKAGE_VERSION:-"next"}"}"

# -----------------------------------------------------------------------------
