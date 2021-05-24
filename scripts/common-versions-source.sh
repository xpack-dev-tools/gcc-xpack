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
    GCC_BRANDING="${BRANDING_PREFIX} MinGW-w64 ${APP_NAME} ${TARGET_BITS}-bit"
    BINUTILS_BRANDING="${BRANDING_PREFIX} MinGW-w64 binutils ${TARGET_BITS}-bit"
  else
    GCC_BRANDING="${BRANDING_PREFIX} ${APP_NAME} ${TARGET_BITS}-bit"
    BINUTILS_BRANDING="${BRANDING_PREFIX} binutils ${TARGET_BITS}-bit"
  fi

  GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-[0-9]*||')"

# -----------------------------------------------------------------------------
  if [[ "${RELEASE_VERSION}" =~ 10\.3\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "linux" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_binutils "2.36.1"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    fix_lto_plugin

    # -------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 9\.3\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "linux" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_binutils "2.35.1"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      build_mingw "8.0.2"
    fi

    # Must be placed after mingw, it checks the mingw version.
    build_gcc "${GCC_VERSION}"

    # -------------------------------------------------------------------------
  elif [[ "${RELEASE_VERSION}" =~ 8\.5\.0-[1] ]]
  then

    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      build_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "linux" -o "${TARGET_PLATFORM}" == "win32" ]
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

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${APP_LC_NAME} version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
