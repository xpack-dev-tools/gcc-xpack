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
  echo
  echo "Testing if gcc starts properly..."

  run_app "${app_folder_path}/bin/gcc" --version
  run_app "${app_folder_path}/bin/g++" --version

  echo
  echo "Testing if gcc compiles simple Hello programs..."

  local tmp="$(mktemp)"
  rm -rf "${tmp}"

  mkdir -p "${tmp}"
  cd "${tmp}"

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > hello.c
#include <stdio.h>

int
main(int argc, char* argv[])
{
  printf("Hello\n");
}
__EOF__

  # Test C compile and link in a single step.
  run_app "${APP_PREFIX}/bin/gcc" -o hello-c1 hello.c
  show_libs hello-c1

  if [ "x$(./hello-c1)x" == "xHellox" ]
  then
    echo "hello-c1 ok"
  else
    exit 1
  fi
}

# -----------------------------------------------------------------------------
