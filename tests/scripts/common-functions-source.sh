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
  echo "Testing if gcc binaries start properly..."

  run_app "${app_folder_path}/bin/gcc" --version
  run_app "${app_folder_path}/bin/g++" --version

  run_app "${app_folder_path}/bin/gcc-ar" --version
  run_app "${app_folder_path}/bin/gcc-nm" --version
  run_app "${app_folder_path}/bin/gcc-ranlib" --version
  run_app "${app_folder_path}/bin/gcov" --version
  run_app "${app_folder_path}/bin/gcov-dump" --version
  run_app "${app_folder_path}/bin/gcov-tool" --version

  if [ -f "${app_folder_path}/bin/gfortran" ]
  then
    run_app "${app_folder_path}/bin/gfortran" --version
  fi

  echo
  echo "Showing configurations..."

  run_app "${app_folder_path}/bin/gcc" -v
  run_app "${app_folder_path}/bin/gcc" -dumpversion
  run_app "${app_folder_path}/bin/gcc" -dumpmachine
  run_app "${app_folder_path}/bin/gcc" -print-multi-lib
  run_app "${app_folder_path}/bin/gcc" -print-search-dirs
  # run_app "${app_folder_path}/bin/gcc" -dumpspecs

  echo
  echo "Testing if gcc compiles simple Hello programs..."

  local tmp="$(mktemp)"
  rm -rf "${tmp}"

  mkdir -p "${tmp}"
  cd "${tmp}"

  local output

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
  run_app "${app_folder_path}/bin/gcc" -o hello-c1 hello.c -v
  show_libs hello-c1

  output="$(run_app_silent "./hello-c1")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "hello-c1 ok"
  else
    exit 1
  fi

  # Test C compile and link in separate steps.
  run_app "${app_folder_path}/bin/gcc" -o hello-c.o -c hello.c
  run_app "${app_folder_path}/bin/gcc" -o hello-c2 hello-c.o
  show_libs hello-c2

  output="$(run_app_silent "./hello-c2")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "hello-c2 ok"
  else
    exit 1
  fi

  # Test LTO C compile and link in a single step.
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c1 hello.c
  show_libs lto-hello-c1

  output="$(run_app_silent "./lto-hello-c1")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "lto-hello-c1 ok"
  else
    exit 1
  fi

  # Test LTO C compile and link in separate steps.
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c.o -c hello.c
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c2 lto-hello-c.o
  show_libs lto-hello-c2

  output="$(run_app_silent "./lto-hello-c2")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "lto-hello-c2 ok"
  else
    exit 1
  fi

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;
}
__EOF__

  # Test C++ compile and link in a single step.
  run_app "${app_folder_path}/bin/g++" -o hello-cpp1 hello.cpp
  show_libs hello-cpp1

  output="$(run_app_silent "./hello-cpp1")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "hello-cpp1 ok"
  else
    exit 1
  fi

  # Test C++ compile and link in separate steps.
  run_app "${app_folder_path}/bin/g++" -o hello-cpp.o -c hello.cpp
  run_app "${app_folder_path}/bin/g++" -o hello-cpp2 hello-cpp.o
  show_libs hello-cpp2

  output="$(run_app_silent "./hello-cpp2")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "hello-cpp2 ok"
  else
    exit 1
  fi

  # Test LTO C++ compile and link in a single step.
  run_app "${app_folder_path}/bin/g++" -flto -o lto-hello-cpp1 hello.cpp
  show_libs lto-hello-cpp1

  output="$(run_app_silent "./lto-hello-cpp1")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "lto-hello-cpp1 ok"
  else
    exit 1
  fi

  # Test LTO C++ compile and link in separate steps.
  run_app "${app_folder_path}/bin/g++" -flto -o lto-hello-cpp.o -c hello.cpp
  run_app "${app_folder_path}/bin/g++" -flto  -o lto-hello-cpp2 lto-hello-cpp.o
  show_libs lto-hello-cpp2

  output="$(run_app_silent "./lto-hello-cpp2")"

  if [ "x${output}x" == "xHellox" ]
  then
    echo "lto-hello-cpp2 ok"
  else
    exit 1
  fi

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > except.cpp
#include <iostream>
#include <exception>

struct MyException : public std::exception {
   const char* what() const throw () {
      return "MyException";
   }
};
 
void
func(void)
{
  throw MyException();
}

int
main(int argc, char* argv[])
{
  try {
    func();
  } catch(MyException& e) {
    std::cout << e.what() << std::endl;
  } catch(std::exception& e) {
    std::cout << "Other" << std::endl;
  }  
}
__EOF__

  # -O0 is an attempt to prevent any interferences with the optimiser.
  run_app "${app_folder_path}/bin/g++" -o except -O0 except.cpp
  show_libs except

  output="$(run_app_silent "./except")"

  if [ "x${output}x" == "xMyExceptionx" ]
  then
    echo "except ok"
  else
    exit 1
  fi

  # Note: __EOF__ is quoted to prevent substitutions here.
  cat <<'__EOF__' > str-except.cpp
#include <iostream>
#include <exception>
 
void
func(void)
{
  throw "MyStringException";
}

int
main(int argc, char* argv[])
{
  try {
    func();
  } catch(const char* msg) {
    std::cout << msg << std::endl;
  } catch(std::exception& e) {
    std::cout << "Other" << std::endl;
  }  
}
__EOF__

  # -O0 is an attempt to prevent any interferences with the optimiser.
  run_app "${app_folder_path}/bin/g++" -o str-except -O0 str-except.cpp
  show_libs str-except

  output="$(run_app_silent "./str-except")"

  if [ "x${output}x" == "xMyStringExceptionx" ]
  then
    echo "str-except ok"
  else
    exit 1
  fi

  # TODO: test creating libraries, static and shared.

  # ---------------------------------------------------------------------------

  echo
  echo "Testing if binutils start properly..."

  run_app "${app_folder_path}/bin/ar" --version
  run_app "${app_folder_path}/bin/as" --version
  run_app "${app_folder_path}/bin/ld" --version
  run_app "${app_folder_path}/bin/nm" --version
  run_app "${app_folder_path}/bin/objcopy" --version
  run_app "${app_folder_path}/bin/objdump" --version
  run_app "${app_folder_path}/bin/ranlib" --version
  run_app "${app_folder_path}/bin/size" --version
  run_app "${app_folder_path}/bin/strings" --version
  run_app "${app_folder_path}/bin/strip" --version

}

# -----------------------------------------------------------------------------
