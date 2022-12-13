# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function tests_run_all()
{
  local test_bin_path="$1"

  # XBB_GCC_VERSION="$(echo "${XBB_RELEASE_VERSION}" | sed -e 's|-.*||')"
  # XBB_GCC_VERSION_MAJOR=$(echo ${XBB_GCC_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  # Call the functions defined in the build code.
  if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
  then
    test_binutils "${test_bin_path}"
  fi

  test_gcc "${test_bin_path}"

  if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
  then
    test_gdb "${test_bin_path}"
  fi
}

# -----------------------------------------------------------------------------
