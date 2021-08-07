#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
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

script_path="$0"
if [[ "${script_path}" != /* ]]
then
  # Make relative path absolute.
  script_path="$(pwd)/$0"
fi

script_name="$(basename "${script_path}")"

script_folder_path="$(dirname "${script_path}")"
script_folder_name="$(basename "${script_folder_path}")"

# =============================================================================

helper_folder_path="$(dirname $(dirname "${script_folder_path}"))/scripts/helper"

source "${helper_folder_path}/test-functions-source.sh"

# -----------------------------------------------------------------------------

message="Test xPack GCC on native platforms"
branch="xpack-develop"
# branch="xpack"

# base_url="https://github.com/xpack-dev-tools/pre-releases/releases/download/experimental/"
base_url="https://github.com/xpack-dev-tools/pre-releases/releases/download/test/"

version="${RELEASE_VERSION:-"current"}"

github_org="xpack-dev-tools"
github_repo="gcc-xpack"

# GITHUB_API_DISPATCH_TOKEN must be present in the environment.

trigger_github_workflow \
  "${github_org}" \
  "${github_repo}" \
  "native.yml" \
  "${branch}" \
  "${base_url}" \
  "${version}"

echo "Done."

# -----------------------------------------------------------------------------