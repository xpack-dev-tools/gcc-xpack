# -----------------------------------------------------------------------------
# This file is part of the xPacks distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the GNU MCU Eclipse build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function xbb_activate_gcc_bootstrap_bins()
{
  export PATH="${APP_PREFIX}${BOOTSTRAP_SUFFIX}/bin:${PATH}"
}

function build_mingw_bootstrap()
{
  # Build a bootstrap toolchain, that runs on Linux and creates Windows
  # binaries.
  (
    # Make the use of XBB GCC explicit.
    prepare_gcc_env "" "-xbb"

    build_binutils "${BINUTILS_VERSION}" "${BOOTSTRAP_SUFFIX}"

    prepare_mingw_env "${MINGW_VERSION}" "${BOOTSTRAP_SUFFIX}"

    # Deploy the headers, they are needed by the compiler.
    build_mingw_headers

    # Build only the compiler, without libraries.
    build_gcc "${GCC_VERSION}" "${BOOTSTRAP_SUFFIX}"

    # Build some native tools.
    build_mingw_libmangle
    build_mingw_gendef
    build_mingw_widl # Refers to mingw headers.

    (
      xbb_activate_gcc_bootstrap_bins

      (
        # Fails if CC is defined to a native compiler.
        prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"

        build_mingw_crt
        build_mingw_winpthreads
      )

      # With the run-time available, build the C/C++ libraries and the rest.
      build_gcc_final
    )
  )
}

function build_common()
{
  # Download GCC separatelly, it'll be use in binutils too.
  download_gcc "${GCC_VERSION}"

  (
    xbb_activate

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      (
        # ---------------------------------------------------------------------

        (
          # Make the use of XBB GCC explicit.
          prepare_gcc_env "" "-xbb"

          # Libraries, required by gcc & other.
          build_gmp "${GMP_VERSION}"
          build_mpfr "${MPFR_VERSION}"
          build_mpc "${MPC_VERSION}"
          build_isl "${ISL_VERSION}"
        )

        # ---------------------------------------------------------------------

        # As usual, for Windows things are more complicated, and require
        # a separate bootstrap that runs on Linux and generates Windows
        # binaries.

        build_mingw_bootstrap "${MINGW_VERSION}" 

        # ---------------------------------------------------------------------

        # Use the newly compiled bootstrap compiler.
        xbb_activate_gcc_bootstrap_bins

        prepare_gcc_env "${CROSS_COMPILE_PREFIX}-"

        build_libiconv "${LIBICONV_VERSION}"

        build_binutils "${BINUTILS_VERSION}"

        prepare_mingw_env "${MINGW_VERSION}"

        build_mingw_headers

        build_mingw_crt
        build_mingw_winpthreads
        build_mingw_winstorecompat
        build_mingw_libmangle
        build_mingw_gendef
        build_mingw_widl

        build_gcc "${GCC_VERSION}"

        # Build GDB.
        build_expat "${EXPAT_VERSION}"
        build_xz "${XZ_VERSION}"

        build_gdb "${GDB_VERSION}"
      )
    else # linux or darwin
      (
        # Libraries, required by gcc & other.
        build_gmp "${GMP_VERSION}"
        build_mpfr "${MPFR_VERSION}"
        build_mpc "${MPC_VERSION}"
        build_isl "${ISL_VERSION}"

        # On Linux the presence of libiconv confuses
        # loader when compiling C++.
        if [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          build_libiconv "${LIBICONV_VERSION}"
        fi

        # macOS has its own binutils.
        if [ "${TARGET_PLATFORM}" == "linux" ]
        then
          build_binutils "${BINUTILS_VERSION}"
        fi
    
        build_gcc "${GCC_VERSION}"

        build_ncurses "${NCURSES_VERSION}"

        # Build GDB.
        build_expat "${EXPAT_VERSION}"
        build_xz "${XZ_VERSION}"

        build_gdb "${GDB_VERSION}"
      )
    fi
  )
}

# -----------------------------------------------------------------------------

# Note 9.x and 10.x are not functional on Windows.

function build_versions()
{
  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    export GCC_BRANDING="${DISTRO_NAME} MinGW-w64 ${APP_NAME} ${TARGET_MACHINE}"
    export BINUTILS_BRANDING="${DISTRO_NAME} MinGW-w64 binutils ${TARGET_MACHINE}"
    export GCC_BOOTSTRAP_BRANDING="${DISTRO_NAME} MinGW-w64 ${APP_NAME}-bootstrap ${TARGET_MACHINE}"
    export BINUTILS_BOOTSTRAP_BRANDING="${DISTRO_NAME} MinGW-w64 binutils-bootstrap ${TARGET_MACHINE}"
  else
    export GCC_BRANDING="${DISTRO_NAME} ${APP_NAME} ${TARGET_MACHINE}"
    export BINUTILS_BRANDING="${DISTRO_NAME} binutils ${TARGET_MACHINE}"
  fi
  export GDB_BRANDING="${DISTRO_NAME} GDB ${TARGET_MACHINE}"

  export GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-.*||')"
  export GCC_VERSION_MAJOR=$(echo ${GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  export BOOTSTRAP_SUFFIX="-bootstrap"

  # https://ftp.gnu.org/gnu/gcc/
  # ---------------------------------------------------------------------------
  if [[ "${RELEASE_VERSION}" =~ 11\.1\.0-[1] ]] \
  || [[ "${RELEASE_VERSION}" =~ 11\.2\.0-[1] ]]
  then

    BINUTILS_VERSION="2.36.1"
    MINGW_VERSION="9.0.0"

    GMP_VERSION="6.2.1" # "6.1.2"
    MPFR_VERSION="4.1.0" # "3.1.6"
    MPC_VERSION="1.2.1" #C"1.1.0" # "1.0.3"
    ISL_VERSION="0.24" # "0.21"

    LIBICONV_VERSION="1.16"
    NCURSES_VERSION="6.2"
    XZ_VERSION="5.2.5" # "5.2.3"
    EXPAT_VERSION="2.4.1" # "2.3.0"
    GDB_VERSION="10.2"

    build_common

  # ---------------------------------------------------------------------------
  # elif [[ "${RELEASE_VERSION}" =~ 10\.3\.0-[1] ]]
  # then

  #   BINUTILS_VERSION="2.36.1"
  #   MINGW_VERSION="9.0.0"

  #   LIBICONV_VERSION="1.16"
  #   NCURSES_VERSION="6.2"
  #   XZ_VERSION="5.2.3"
  #   EXPAT_VERSION="2.3.0"
  #   GDB_VERSION="10.2"

  #   build_common

  # ---------------------------------------------------------------------------
  # elif [[ "${RELEASE_VERSION}" =~ 9\.3\.0-[1] ]] \
  #   || [[ "${RELEASE_VERSION}" =~ 9\.4\.0-[1] ]]
  # then

  #   BINUTILS_VERSION="2.35.2"
  #   MINGW_VERSION="8.0.2"

  #   LIBICONV_VERSION="1.16"
  #   NCURSES_VERSION="6.2"
  #   XZ_VERSION="5.2.3"
  #   EXPAT_VERSION="2.3.0"
  #   GDB_VERSION="9.2"

  #   build_common

  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 8\.5\.0-[12] ]]
  then

    BINUTILS_VERSION="2.34"
    MINGW_VERSION="8.0.2"

    LIBICONV_VERSION="1.16"
    NCURSES_VERSION="6.2"
    XZ_VERSION="5.2.3"
    EXPAT_VERSION="2.3.0"
    GDB_VERSION="9.1"

    build_common

  # ---------------------------------------------------------------------------
  else
    echo "Unsupported ${APP_LC_NAME} version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
