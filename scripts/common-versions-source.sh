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

function do_build_versions()
{
  # The \x2C is a comma in hex; without this trick the regular expression
  # that processes this string in the Makefile, silently fails and the 
  # bfdver.h file remains empty.

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    BRANDING="${BRANDING_PREFIX} Mingw-w64 ${APP_NAME}\x2C ${TARGET_BITS}-bit"
  else
    BRANDING="${BRANDING_PREFIX} ${APP_NAME}\x2C ${TARGET_BITS}-bit"
  fi

  # gcc_BUILD_GIT_BRANCH=${gcc_BUILD_GIT_BRANCH:-"master"}
  # gcc_BUILD_GIT_COMMIT=${gcc_BUILD_GIT_COMMIT:-"HEAD"}

  WITH_GLIBC=""

  # Use this for custom content, otherwise the generic README-OUT.md 
  # will be copied to the archive.
  # README_OUT_FILE_NAME=${README_OUT_FILE_NAME:-"README-${RELEASE_VERSION}.md"}

  if [[ "${RELEASE_VERSION}" =~ 9\.3\.0-[1] ]]
  then

    do_zlib "1.2.11"

    # The classical GCC libraries.
    do_gmp "6.2.0"
    do_mpfr "4.0.2"
    do_mpc "1.1.0"
    do_isl "0.22"

    # Introduced with 9.x, useless for previous versions.
    # do_zstd "1.4.4"

    if [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      do_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      : # do_mingw "" ""
    else
      do_native_gcc "9.3.0"
    fi

  elif [[ "${RELEASE_VERSION}" =~ 8\.4\.0-[1] ]]
  then

    # -------------------------------------------------------------------------

    do_zlib "1.2.11"

    if [ "${WITH_GLIBC}" == "y" && "${TARGET_PLATFORM}" == "linux" ]
    then
      # Better do it before gmp.
      do_glibc "2.31"
    fi

    # The classical GCC libraries.
    do_gmp "6.2.0"
    do_mpfr "4.0.2"
    do_mpc "1.1.0"
    do_isl "0.22"

    if [ "${TARGET_PLATFORM}" == "darwin" -o "${TARGET_PLATFORM}" == "win32" ]
    then
      do_libiconv "1.16"
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      : # do_mingw "" ""
    else
      do_native_gcc "8.4.0"
    fi

    # -------------------------------------------------------------------------
  else
    echo "Unsupported ${APP_LC_NAME} version ${RELEASE_VERSION}."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
