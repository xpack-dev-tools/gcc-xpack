# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function gcc_build_common()
{
  # Download GCC separatelly, it'll be use in binutils too.
  gcc_download "${XBB_GCC_VERSION}"

  if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
  then
    # -------------------------------------------------------------------------

    # As usual, for Windows things are more complicated, and require
    # a separate bootstrap that runs on Linux and generates Windows
    # binaries.

    # Number
    XBB_MINGW_VERSION_MAJOR=$(xbb_get_version_major "${XBB_MINGW_VERSION}")

    XBB_MINGW_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.git.patch"

    mingw_download "${XBB_MINGW_VERSION}"

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    xbb_reset_env
    xbb_set_target "mingw-w64-native"

    # Build the bootstrap (a native Linux application).
    # The result is in x86_64-pc-linux-gnu/x86_64-w64-mingw32.
    gcc_mingw_build_dependencies

    gcc_mingw_build_all_triplets

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    # Before set target (to possibly update CC & co variables).
    xbb_activate_installed_bin

    xbb_set_target "requested"

    gcc_mingw_build_dependencies

    expat_build "${XBB_EXPAT_VERSION}"

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    binutils_build "${XBB_BINUTILS_VERSION}"

    # Build mingw-w64 components.
    mingw_build_headers
    mingw_build_widl --program-prefix=
    mingw_build_libmangle
    mingw_build_gendef --program-prefix=

    mingw_build_crt
    mingw_build_winpthreads
    mingw_build_winstorecompat

    gcc_build "${XBB_GCC_VERSION}"

    gdb_build "${XBB_GDB_VERSION}"

  else # linux or darwin

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    # None

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_reset_env
    # Before set target (to possibly update CC & co variables).
    # xbb_activate_installed_bin

    xbb_set_target "requested"

    # On Linux the presence of libiconv confuses
    # the loader when compiling C++, and the tests fail.
    # /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: /home/ilg/Work/xpack-dev-tools/gcc-xpack.git/build/linux-x64/application/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib64/libstdc++.a(numeric_members_cow.o): in function `std::__narrow_multibyte_chars(char const*, __locale_struct*)':
    # (.text._ZSt24__narrow_multibyte_charsPKcP15__locale_struct+0x93): undefined reference to `libiconv_open'
    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" ]
    then
      libiconv_build "${XBB_LIBICONV_VERSION}"
    fi

    zlib_build "${XBB_ZLIB_VERSION}"

    # Libraries, required by gcc & other.
    gmp_build "${XBB_GMP_VERSION}"
    mpfr_build "${XBB_MPFR_VERSION}"
    mpc_build "${XBB_MPC_VERSION}"
    isl_build "${XBB_ISL_VERSION}"

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" -a "${XBB_REQUESTED_HOST_ARCH}" == "arm64" ]
    then
      : # Skip gdb dependencies, gdb not available on Apple Silicon
    else
      ncurses_build "${XBB_NCURSES_VERSION}"

      expat_build "${XBB_EXPAT_VERSION}"
      xz_build "${XBB_XZ_VERSION}"
    fi

    # depends on zlib, xz, (lz4)
    zstd_build "${XBB_ZSTD_VERSION}"

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # macOS has its own binutils.
    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "linux" ]
    then
      binutils_build "${XBB_BINUTILS_VERSION}"
    fi

    gcc_build "${XBB_GCC_VERSION}"

    if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "darwin" -a "${XBB_REQUESTED_HOST_ARCH}" == "arm64" ]
    then
      : # Skip gdb, not available on Apple Silicon
    else
      gdb_build "${XBB_GDB_VERSION}"
    fi
  fi
}

# -----------------------------------------------------------------------------

function application_build_versioned_components()
{
  if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
  then
    export XBB_GCC_BOOTSTRAP_BRANDING="${XBB_APPLICATION_DISTRO_NAME} MinGW-w64 ${XBB_APPLICATION_NAME}-bootstrap ${XBB_TARGET_MACHINE}"
    export XBB_BINUTILS_BOOTSTRAP_BRANDING="${XBB_APPLICATION_DISTRO_NAME} MinGW-w64 binutils-bootstrap ${XBB_TARGET_MACHINE}"

    export XBB_GCC_BRANDING="${XBB_APPLICATION_DISTRO_NAME} MinGW-w64 ${XBB_APPLICATION_NAME} ${XBB_REQUESTED_TARGET_MACHINE}"
    export XBB_BINUTILS_BRANDING="${XBB_APPLICATION_DISTRO_NAME} MinGW-w64 binutils ${XBB_REQUESTED_TARGET_MACHINE}"
  else
    export XBB_GCC_BRANDING="${XBB_APPLICATION_DISTRO_NAME} ${XBB_APPLICATION_NAME} ${XBB_REQUESTED_TARGET_MACHINE}"
    export XBB_BINUTILS_BRANDING="${XBB_APPLICATION_DISTRO_NAME} binutils ${XBB_REQUESTED_TARGET_MACHINE}"
  fi
  export XBB_GDB_BRANDING="${XBB_APPLICATION_DISTRO_NAME} GDB ${XBB_REQUESTED_TARGET_MACHINE}"

  export XBB_GCC_VERSION="$(xbb_strip_version_pre_release "${XBB_RELEASE_VERSION}")"
  export XBB_GCC_VERSION_MAJOR=$(xbb_get_version_major "${XBB_GCC_VERSION}")

  XBB_MINGW_TRIPLETS=( "x86_64-w64-mingw32" "i686-w64-mingw32" )
  # XBB_MINGW_TRIPLETS=( "x86_64-w64-mingw32" ) # Use it temporarily during tests.
  # XBB_MINGW_TRIPLETS=( "i686-w64-mingw32" ) # Use it temporarily during tests.

  # https://ftp.gnu.org/gnu/gcc/
  # ---------------------------------------------------------------------------
  if [[ "${XBB_RELEASE_VERSION}" =~ 12[.][3][.].*-.* ]]
  then
    # https://ftp.gnu.org/gnu/binutils/
    XBB_BINUTILS_VERSION="2.41" # "2.39"
    
    # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/
    XBB_MINGW_VERSION="11.0.1" # "10.0.0"

    # https://gmplib.org/download/gmp/
    XBB_GMP_VERSION="6.3.0" # "6.2.1"
    # https://www.mpfr.org/history.html
    XBB_MPFR_VERSION="4.2.1" # "4.1.0"
    # https://www.multiprecision.org/mpc/download.html
    XBB_MPC_VERSION="1.2.1"
    # https://sourceforge.net/projects/libisl/files/
    XBB_ISL_VERSION="0.26" # "0.24"
    # https://github.com/facebook/zstd/releases
    XBB_ZSTD_VERSION="1.5.5" # "1.5.2"

    # https://zlib.net/fossils/
    XBB_ZLIB_VERSION="1.2.13" # "1.2.11"

    # https://ftp.gnu.org/pub/gnu/libiconv/
    XBB_LIBICONV_VERSION="1.17"
    # https://ftp.gnu.org/gnu/ncurses/
    XBB_NCURSES_VERSION="6.4" # "6.3"
    # https://sourceforge.net/projects/lzmautils/files/
    XBB_XZ_VERSION="5.4.4" # "5.2.5"
    # https://github.com/libexpat/libexpat/releases
    XBB_EXPAT_VERSION="2.5.0" # "2.4.8"
    # https://ftp.gnu.org/gnu/gdb/
    XBB_GDB_VERSION="13.2" # "12.1"

    gcc_build_common

    # -------------------------------------------------------------------------
  elif [[ "${XBB_RELEASE_VERSION}" =~ 12[.][12][.].*-.* ]]
  then
    # https://ftp.gnu.org/gnu/binutils/
    if [[ "${XBB_RELEASE_VERSION}" =~ 12[.]1[.].*-.* ]]
    then
      XBB_BINUTILS_VERSION="2.38"
    else
      XBB_BINUTILS_VERSION="2.39"
    fi

    # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/
    XBB_MINGW_VERSION="10.0.0"

    # https://gmplib.org/download/gmp/
    XBB_GMP_VERSION="6.2.1"
    # https://www.mpfr.org/history.html
    XBB_MPFR_VERSION="4.1.0"
    # https://www.multiprecision.org/mpc/download.html
    XBB_MPC_VERSION="1.2.1"
    # https://sourceforge.net/projects/libisl/files/
    XBB_ISL_VERSION="0.24"
    # https://github.com/facebook/zstd/releases
    XBB_ZSTD_VERSION="1.5.2"

    # https://zlib.net/fossils/
    XBB_ZLIB_VERSION="1.2.11"

    # https://ftp.gnu.org/pub/gnu/libiconv/
    XBB_LIBICONV_VERSION="1.17"
    # https://ftp.gnu.org/gnu/ncurses/
    XBB_NCURSES_VERSION="6.3"
    # https://sourceforge.net/projects/lzmautils/files/
    XBB_XZ_VERSION="5.2.5"
    # https://github.com/libexpat/libexpat/releases
    XBB_EXPAT_VERSION="2.4.8"
    # https://ftp.gnu.org/gnu/gdb/
    XBB_GDB_VERSION="12.1"

    gcc_build_common

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
