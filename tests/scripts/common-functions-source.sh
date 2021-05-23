# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Common functions used in various tests.
#
# Requires 
# - app_folder_path
# - test_folder_path
# - archive_platform (win32|linux|darwin)

# -----------------------------------------------------------------------------

function run_tests()
{
  
  GCC_VERSION="$(echo "${RELEASE_VERSION}" | sed -e 's|-[0-9]*||')"

  # Call the functions defined in the build code.
  test_gcc

  if [ "${TARGET_PLATFORM}" != "darwin" ]
  then
    test_binutils
  fi
}

# -----------------------------------------------------------------------------
