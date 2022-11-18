# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function build_mingw_gcc_dependencies()
{
  build_libiconv "${XBB_LIBICONV_VERSION}"

  # New zlib, used in most of the tools.
  # depends=('glibc')
  build_zlib "${XBB_ZLIB_VERSION}"

  # Libraries, required by gcc & other.
  # depends=('gcc-libs' 'sh')
  build_gmp "${XBB_GMP_VERSION}"

  # depends=('gmp>=5.0')
  build_mpfr "${XBB_MPFR_VERSION}"

  # depends=('mpfr')
  build_mpc "${XBB_MPC_VERSION}"

  # depends=('gmp')
  build_isl "${XBB_ISL_VERSION}"

  # depends=('sh')
  build_xz "${XBB_XZ_VERSION}"

  # depends on zlib, xz, (lz4)
  build_zstd "${XBB_ZSTD_VERSION}"
}

function build_mingw_gcc_all_triplets()
{
  for triplet in "${XBB_MINGW_TRIPLETS[@]}"
  do

    # build_mingw_binutils "${XBB_BINUTILS_VERSION}" "${triplet}"
    build_binutils "${XBB_BINUTILS_VERSION}" --triplet="${triplet}"

    # Deploy the headers, they are needed by the compiler.
    build_mingw_headers --triplet="${triplet}"

    # Build only the compiler, without libraries.
    build_mingw_gcc_first "${XBB_GCC_VERSION}" --triplet="${triplet}"

    # Refers to mingw headers.
    build_mingw_widl --triplet="${triplet}"

    # Build some native tools.
    build_mingw_libmangle --triplet="${triplet}"
    build_mingw_gendef --triplet="${triplet}"

    (
      xbb_activate_installed_bin
      (
        # Fails if CC is defined to a native compiler.
        xbb_prepare_gcc_env "${triplet}-"

        build_mingw_crt --triplet="${triplet}"
        build_mingw_winpthreads --triplet="${triplet}"
      )

      # With the run-time available, build the C/C++ libraries and the rest.
      build_mingw_gcc_final --triplet="${triplet}"
    )

  done
}

function build_common()
{
  # Download GCC separatelly, it'll be use in binutils too.
  download_gcc "${XBB_GCC_VERSION}"

  if [ "${XBB_REQUESTED_HOST_PLATFORM}" == "win32" ]
  then
    # -------------------------------------------------------------------------

    # As usual, for Windows things are more complicated, and require
    # a separate bootstrap that runs on Linux and generates Windows
    # binaries.

    # Number
    XBB_MINGW_VERSION_MAJOR=$(echo ${XBB_MINGW_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

    XBB_MINGW_GCC_PATCH_FILE_NAME="gcc-${XBB_GCC_VERSION}-cross.patch.diff"

    download_mingw "${XBB_MINGW_VERSION}"

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    xbb_set_target "mingw-w64-native"

    # Build the bootstrap (a native Linux application).
    # The result is in x86_64-pc-linux-gnu/x86_64-w64-mingw32.
    build_mingw_gcc_dependencies

    build_mingw_gcc_all_triplets

    xbb_activate_installed_bin

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_set_target

    build_mingw_gcc_dependencies

    build_expat "${XBB_EXPAT_VERSION}"
    build_xz "${XBB_XZ_VERSION}"

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    build_binutils "${XBB_BINUTILS_VERSION}"

    build_mingw_headers
    build_mingw_widl --program-prefix=
    build_mingw_libmangle
    build_mingw_gendef --program-prefix=

    build_mingw_crt
    build_mingw_winpthreads
    build_mingw_winstorecompat

    build_gcc "${XBB_GCC_VERSION}"

    build_gdb "${XBB_GDB_VERSION}"

  else # linux or darwin

    # -------------------------------------------------------------------------
    # Build the native dependencies.

    # None

    # -------------------------------------------------------------------------
    # Build the target dependencies.

    xbb_set_target

    # On Linux the presence of libiconv confuses
    # the loader when compiling C++, and the tests fail.
    # /home/ilg/Work/gcc-xpack.git/build/linux-x64/application/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../x86_64-pc-linux-gnu/bin/ld: /home/ilg/Work/gcc-xpack.git/build/linux-x64/application/lib/gcc/x86_64-pc-linux-gnu/12.2.0/../../../../lib64/libstdc++.a(numeric_members_cow.o): in function `std::__narrow_multibyte_chars(char const*, __locale_struct*)':
    # (.text._ZSt24__narrow_multibyte_charsPKcP15__locale_struct+0x93): undefined reference to `libiconv_open'
    if [ "${XBB_HOST_PLATFORM}" == "darwin" ]
    then
      build_libiconv "${XBB_LIBICONV_VERSION}"
    fi

    build_zlib "${XBB_ZLIB_VERSION}"

    # Libraries, required by gcc & other.
    build_gmp "${XBB_GMP_VERSION}"
    build_mpfr "${XBB_MPFR_VERSION}"
    build_mpc "${XBB_MPC_VERSION}"
    build_isl "${XBB_ISL_VERSION}"

    if [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" ]
    then
      : # Skip gdb dependencies, gdb not available on Apple Silicon
    else
      build_ncurses "${XBB_NCURSES_VERSION}"

      build_expat "${XBB_EXPAT_VERSION}"
      build_xz "${XBB_XZ_VERSION}"
    fi

    # depends on zlib, xz, (lz4)
    build_zstd "${XBB_ZSTD_VERSION}"

    # -------------------------------------------------------------------------
    # Build the application binaries.

    xbb_set_executables_install_path "${XBB_APPLICATION_INSTALL_FOLDER_PATH}"
    xbb_set_libraries_install_path "${XBB_DEPENDENCIES_INSTALL_FOLDER_PATH}"

    # macOS has its own binutils.
    if [ "${XBB_HOST_PLATFORM}" == "linux" ]
    then
      build_binutils "${XBB_BINUTILS_VERSION}"
    fi

    build_gcc "${XBB_GCC_VERSION}"

    if [ "${XBB_HOST_PLATFORM}" == "darwin" -a "${XBB_HOST_ARCH}" == "arm64" ]
    then
      : # Skip gdb, not available on Apple Silicon
    else
      build_gdb "${XBB_GDB_VERSION}"
    fi
  fi
}

# -----------------------------------------------------------------------------

function build_application_versioned_components()
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

  export XBB_GCC_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"
  export XBB_GCC_VERSION_MAJOR=$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  XBB_MINGW_TRIPLETS=( "x86_64-w64-mingw32" "i686-w64-mingw32" )
  # XBB_MINGW_TRIPLETS=( "x86_64-w64-mingw32" ) # Use it temporarily during tests.
  # XBB_MINGW_TRIPLETS=( "i686-w64-mingw32" ) # Use it temporarily during tests.

  # https://ftp.gnu.org/gnu/gcc/
  # ---------------------------------------------------------------------------
  if [[ "${XBB_RELEASE_VERSION}" =~ 12\.[12]\.0-[12] ]]
  then
    # https://ftp.gnu.org/gnu/binutils/
    XBB_BINUTILS_VERSION="2.38"
    # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/
    XBB_MINGW_VERSION="10.0.0"

    # https://gmplib.org/download/gmp/
    XBB_GMP_VERSION="6.2.1"
    # http://www.mpfr.org/history.html
    XBB_MPFR_VERSION="4.1.0"
    # https://www.multiprecision.org/mpc/download.html
    XBB_MPC_VERSION="1.2.1"
    # https://sourceforge.net/projects/libisl/files/
    XBB_ISL_VERSION="0.24"
    # https://github.com/facebook/zstd/releases
    XBB_ZSTD_VERSION="1.5.2"

    # http://zlib.net/fossils/
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

    build_common

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${XBB_APPLICATION_LOWER_CASE_NAME} version ${XBB_RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
