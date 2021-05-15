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
  # The \x2C is a comma in hex; without this trick the regular expression
  # that processes this string in the Makefile, silently fails and the 
  # bfdver.h file remains empty.

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    GCC_BRANDING="${BRANDING_PREFIX} MinGW-w64 ${APP_NAME}\x2C ${TARGET_BITS}-bit"
    BINUTILS_BRANDING="${BRANDING_PREFIX} MinGW-w64 binutils\x2C ${TARGET_BITS}-bit"
  else
    GCC_BRANDING="${BRANDING_PREFIX} ${APP_NAME}\x2C ${TARGET_BITS}-bit"
    BINUTILS_BRANDING="${BRANDING_PREFIX} binutils\x2C ${TARGET_BITS}-bit"
    GLIBC_BRANDING="${BRANDING_PREFIX} GNU libc\x2C ${TARGET_BITS}-bit"
  fi

  WITH_GLIBC=""

  GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-[0-9]*||')"

  # Use this for custom content, otherwise the generic README-OUT.md 
  # will be copied to the archive.
  # README_OUT_FILE_NAME=${README_OUT_FILE_NAME:-"README-${RELEASE_VERSION}.md"}

  if [[ "${RELEASE_VERSION}" =~ 9\.3\.0-[1] ]]
  then

    build_zlib "1.2.11"

    # The classical GCC libraries.
    build_gmp "6.2.0"
    build_mpfr "4.0.2"
    build_mpc "1.1.0"
    build_isl "0.22"

    # Introduced with 9.x, useless for previous versions.
    # build_zstd "1.4.4"

    if [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "7.0.0"
    fi

    build_gcc "9.3.0"
    
  elif [[ "${RELEASE_VERSION}" =~ 8\.5\.0-[1] ]]
  then

    # -------------------------------------------------------------------------

    build_zlib "1.2.11"

    # The classical GCC libraries.
    build_gmp "6.2.1"
    build_mpfr "4.1.0"
    build_mpc "1.2.1"
    build_isl "0.24"

    # 
    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_libiconv "1.16"
    fi

    # TODO check if it can be used on macOS.
#    if [ "${TARGET_PLATFORM}" == "linux" -o "${TARGET_PLATFORM}" == "win32" ]
#    then
      build_binutils "2.35.2" # "2.36.1" Fails on Darwin
#    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    # -------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 8\.4\.0-[1] ]]
  then

    # -------------------------------------------------------------------------

    build_zlib "1.2.11"

    # The classical GCC libraries.
    build_gmp "6.2.0"
    build_mpfr "4.0.2"
    build_mpc "1.1.0"
    build_isl "0.22"

    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "7.0.0"
    fi

    # TODO check if it can be used on macOS.
    if [ "${TARGET_PLATFORM}" == "linux" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_binutils "2.34"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "8.4.0"

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${APP_LC_NAME} version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
