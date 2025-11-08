#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# DO NOT EDIT!
# Automatically generated from npm-packages-helper/templates/*.
#
# This file is part of the xPack project (http://xpack.github.io).
# Copyright (c) 2020-2025 Liviu Ionescu. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
#
# If a copy of the license was not distributed with this file, it can
# be obtained from https://opensource.org/licenses/mit.
#
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

argv="$@"

helper_folder_path="$(dirname ${script_folder_path})/xpacks/@xpack-dev-tools/xbb-helper"

source "${helper_folder_path}/maintainance-scripts/download-sourceforge-source.sh"

# -----------------------------------------------------------------------------

# Redefine to skip macOS binaries.
function download_sourceforge_2025()
{
  local name="$1"
  local version="$2"
  local threshold=$3

  download_sourceforge_one "${name}" "${version}" "win32-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-x64" ${threshold}
  download_sourceforge_one "${name}" "${version}" "linux-arm64" ${threshold}
}

# -----------------------------------------------------------------------------

percentage=60
threshold=$(( 32767 * ( 100 - percentage ) / 100 ))
# echo "Threshold: ${threshold}"

download_sourceforge_2025 "gcc" "14.2.0-1" ${threshold}
download_sourceforge_2025 "gcc" "13.3.0-1" ${threshold}
download_sourceforge_2025 "gcc" "12.4.0-1" ${threshold}
download_sourceforge_2025 "gcc" "11.5.0-1" ${threshold}

rm -rf "${HOME}/tmp/sourceforge"

echo
echo "Done."

# -----------------------------------------------------------------------------

