# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function tests_update_system()
{
  local image_name="$1"

  # Make sure that the minimum prerequisites are met.
  if [[ ${image_name} == github-actions-ubuntu* ]]
  then
    sudo apt-get update
    # To make 32-bit tests possible.
    sudo apt-get -qq install --yes g++-multilib
  else
    export XBB_SKIP_32_BIT_TESTS="y"
  fi
}

# -----------------------------------------------------------------------------
