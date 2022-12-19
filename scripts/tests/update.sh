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
    run_verbose sudo apt-get update
    # To make 32-bit tests possible.
    run_verbose sudo apt-get -qq install --yes g++-multilib
  elif [[ ${image_name} == *ubuntu* ]] || [[ ${image_name} == *debian* ]]
  then
    if [ "$(uname -m)" == "x86_64" ]
    then
      run_verbose apt-get -qq install --yes g++ g++-multilib
    else
      run_verbose apt-get -qq install --yes g++
    fi
  elif [[ ${image_name} == *raspbian* ]]
  then
    run_verbose apt-get -qq install --yes g++
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *centos* ]] || [[ ${image_name} == *redhat* ]] || [[ ${image_name} == *fedora* ]]
  then
    run_verbose yum install --assumeyes --quiet gcc-c++ glibc glibc-common
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *suse* ]]
  then
    run_verbose zypper --quiet --no-gpg-checks install --no-confirm gcc-c++ glibc
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *manjaro* ]]
  then
    run_verbose pacman -S --quiet --noconfirm --noprogressbar gcc
    export XBB_SKIP_32_BIT_TESTS="y"
  elif [[ ${image_name} == *archlinux* ]]
  then
    run_verbose pacman -S --quiet --noconfirm --noprogressbar gcc
    export XBB_SKIP_32_BIT_TESTS="y"
  else
    export XBB_SKIP_32_BIT_TESTS="y"
  fi

  echo
  echo "The system C/C++ libraries..."
  find /usr/lib* /lib -name 'libc.*' -o -name 'libstdc++.*' -o -name 'libgcc_s.*'
}

# -----------------------------------------------------------------------------
