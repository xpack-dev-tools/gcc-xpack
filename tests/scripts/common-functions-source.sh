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
  echo "Show configuration..."
  run_app "${app_folder_path}/bin/gcc" -v

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
  run_app "${app_folder_path}/bin/gcc" -o hello-c1 hello.c -v
  show_libs hello-c1

  if [ "x$(./hello-c1)x" == "xHellox" ]
  then
    echo "hello-c1 ok"
  else
    exit 1
  fi

  # Test C compile and link in separate steps.
  run_app "${app_folder_path}/bin/gcc" -o hello-c.o -c hello.c
  run_app "${app_folder_path}/bin/gcc" -o hello-c2 hello-c.o
  show_libs hello-c2

  if [ "x$(./hello-c2)x" == "xHellox" ]
  then
    echo "hello-c2 ok"
  else
    exit 1
  fi

  # Test LTO C compile and link in a single step.
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c1 hello.c
  show_libs lto-hello-c1

  if [ "x$(./lto-hello-c1)x" == "xHellox" ]
  then
    echo "lto-hello-c1 ok"
  else
    exit 1
  fi

  # Test LTO C compile and link in separate steps.
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c.o -c hello.c
  run_app "${app_folder_path}/bin/gcc" -flto -o lto-hello-c2 lto-hello-c.o
  show_libs lto-hello-c2

  if [ "x$(./lto-hello-c2)x" == "xHellox" ]
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

  if [ "x$(./hello-cpp1)x" == "xHellox" ]
  then
    echo "hello-cpp1 ok"
  else
    exit 1
  fi

  # Test C++ compile and link in separate steps.
  run_app "${app_folder_path}/bin/g++" -o hello-cpp.o -c hello.cpp
  run_app "${app_folder_path}/bin/g++" -o hello-cpp2 hello-cpp.o
  show_libs hello-cpp2

  if [ "x$(./hello-cpp2)x" == "xHellox" ]
  then
    echo "hello-cpp2 ok"
  else
    exit 1
  fi

  # Test LTO C++ compile and link in a single step.
  run_app "${app_folder_path}/bin/g++" -flto -o lto-hello-cpp1 hello.cpp
  show_libs lto-hello-cpp1

  if [ "x$(./lto-hello-cpp1)x" == "xHellox" ]
  then
    echo "lto-hello-cpp1 ok"
  else
    exit 1
  fi

  # Test LTO C++ compile and link in separate steps.
  run_app "${app_folder_path}/bin/g++" -flto -o lto-hello-cpp.o -c hello.cpp
  run_app "${app_folder_path}/bin/g++" -flto  -o lto-hello-cpp2 lto-hello-cpp.o
  show_libs lto-hello-cpp2

  if [ "x$(./lto-hello-cpp2)x" == "xHellox" ]
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

  if [ "x$(./except)x" == "xMyExceptionx" ]
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

  if [ "x$(./str-except)x" == "xMyStringExceptionx" ]
  then
    echo "str-except ok"
  else
    exit 1
  fi

  # TODO: test creating libraries, static and shared.
  
}

# -----------------------------------------------------------------------------
