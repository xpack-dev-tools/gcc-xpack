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
  echo
  echo "[${FUNCNAME[0]} $@]"

  local test_bin_path="$1"

  # Call the functions defined in the build code.
  if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
  then
    binutils_test "${test_bin_path}"
  fi

  gcc_test "${test_bin_path}"

  if [ "${XBB_HOST_PLATFORM}" != "darwin" ]
  then
    gdb_test "${test_bin_path}"
  fi
}

# -----------------------------------------------------------------------------
