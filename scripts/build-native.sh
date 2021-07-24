#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2019 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Safety settings (see https://gist.github.com/ilg-ul/383869cbb01f61a51c4d).

if [[ ! -z ${DEBUG} ]]
then
  set ${DEBUG} # Activate the expand mode if DEBUG is anything but empty.
else
  DEBUG=""
fi

set -o errexit # Exit if command failed.
set -o pipefail # Exit if pipe failed.
set -o nounset # Exit if variable not set.

# Remove the initial space and instead use '\n'.
IFS=$'\n\t'

# -----------------------------------------------------------------------------
# Identify the script location, to reach, for example, the helper scripts.

build_script_path="$0"
if [[ "${build_script_path}" != /* ]]
then
  # Make relative path absolute.
  build_script_path="$(pwd)/$0"
fi

script_folder_path="$(dirname "${build_script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

helper_folder_path="${script_folder_path}/helper"

# -----------------------------------------------------------------------------

# Script to build a native xPack GCC, which uses the
# tools and libraries available on the host machine. It is generally
# intended for development and creating customised versions (as opposed
# to the build intended for creating distribution packages).
#
# Developed on Ubuntu 18 LTS x64. 

# -----------------------------------------------------------------------------

echo
echo "xPack GCC native build script."

host_functions_script_path="${script_folder_path}/helper/host-functions-source.sh"
source "${host_functions_script_path}"

# common_functions_script_path="${script_folder_path}/common-functions-source.sh"
# source "${common_functions_script_path}"

defines_script_path="${script_folder_path}/defs-source.sh"
source "${defines_script_path}"

host_detect
export TARGET_BITS="${HOST_BITS}"

# -----------------------------------------------------------------------------

help_message="    bash $0 [--win32] [--win64] [--linux32] [--linux64] [--arm32] [--arm64] [--osx] [--all] [clean|cleanlibs|cleanall|preload-images] [--env-file file] [--disable-strip] [--without-tests] [--without-pdf] [--with-html] [--develop] [--debug] [--jobs N] [--help]"
host_native_options "${help_message}" $@

# Intentionally moved after option parsing.
echo
echo "Host helper functions source script: \"${host_functions_script_path}\"."
# echo "Common functions source script: \"${common_functions_script_path}\"."
echo "Definitions source script: \"${defines_script_path}\"."

# -----------------------------------------------------------------------------

host_common

prepare_xbb_env
prepare_xbb_extras

tests_initialize

# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

echo
echo "Here we go..."
echo

build_versions

# -----------------------------------------------------------------------------

prime_wine

tests_run

# -----------------------------------------------------------------------------

host_stop_timer

host_notify_completed

# Completed successfully.
exit 0

# -----------------------------------------------------------------------------
