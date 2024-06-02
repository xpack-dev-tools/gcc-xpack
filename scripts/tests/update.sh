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
    :
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]]
  then
    :
  elif [[ ${image_name} == *raspbian* ]]
  then
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    export XBB_SKIP_32_BIT_TESTS="y"
    yum install -y glibc-static libstdc++-static
  elif [[ ${image_name} == *suse* ]]
  then
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *manjaro* ]]
  then
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *archlinux* ]]
  then
    export XBB_SKIP_32_BIT_TESTS="y"
  else
    export XBB_SKIP_32_BIT_TESTS="y"
  fi

  echo
  echo "The system C/C++ libraries..."
  find /usr/lib* /lib -name 'libc.*' -o -name 'libstdc++.*' -o -name 'libgcc_s.*'
}

# -----------------------------------------------------------------------------
