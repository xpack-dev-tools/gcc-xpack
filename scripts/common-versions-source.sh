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

function build_versions()
{
  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    export GCC_BRANDING="${BRANDING_PREFIX} MinGW-w64 ${APP_NAME} ${TARGET_BITS}-bit"
    export BINUTILS_BRANDING="${BRANDING_PREFIX} MinGW-w64 binutils ${TARGET_BITS}-bit"
    export GCC_BOOTSTRAP_BRANDING="${BRANDING_PREFIX} MinGW-w64 ${APP_NAME}-bootstrap ${TARGET_BITS}-bit"
    export BINUTILS_BOOTSTRAP_BRANDING="${BRANDING_PREFIX} MinGW-w64 binutils-bootstrap ${TARGET_BITS}-bit"
  else
    export GCC_BRANDING="${BRANDING_PREFIX} ${APP_NAME} ${TARGET_BITS}-bit"
    export BINUTILS_BRANDING="${BRANDING_PREFIX} binutils ${TARGET_BITS}-bit"
  fi

  export GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-[0-9]*||')"
  export GCC_VERSION_MAJOR=$(echo ${GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')


  # ---------------------------------------------------------------------------
  if [[ "${RELEASE_VERSION}" =~ 11\.1\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # The existing XBB patchelf get confused by libz.
      build_patchelf "0.12"
    fi


    build_zlib "1.2.11"

    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    if [ "${TARGET_PLATFORM}" != "linux" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      build_binutils "2.36.1"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      fix_lto_plugin
    fi

  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 10\.3\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # Because libz confuses the existing XBB patchelf.
      build_patchelf "0.12"
    fi

    build_zlib "1.2.11"

    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    if [ "${TARGET_PLATFORM}" != "linux" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      build_binutils "2.36.1"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      fix_lto_plugin
    fi

  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 9\.3\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # Because libz confuses the existing XBB patchelf.
      build_patchelf "0.12"
    fi

    build_zlib "1.2.11"

    # Versions from gcc contrib/download-prerequisites.
    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    if [ "${TARGET_PLATFORM}" != "linux" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      build_binutils "2.35.2"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      fix_lto_plugin
    fi

  # ---------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 8\.5\.0-[12] ]]
  then

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # Because libz confuses the existing XBB patchelf.
      build_patchelf "0.12"
    fi

    build_zlib "1.2.11"

    # Versions from gcc contrib/download-prerequisites.
    build_gmp "6.1.0"
    build_mpfr "3.1.4"
    build_mpc "1.0.3"
    build_isl "0.18"

    if [ "${TARGET_PLATFORM}" != "linux" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      build_binutils "2.34"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      fix_lto_plugin
    fi

  # ---------------------------------------------------------------------------
  else
    echo "Unsupported ${APP_LC_NAME} version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
