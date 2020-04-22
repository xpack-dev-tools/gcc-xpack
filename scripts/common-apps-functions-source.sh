# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software 
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# Helper script used in the second edition of the xPack build 
# scripts. As the name implies, it should contain only functions and 
# should be included with 'source' by the container build scripts.

# -----------------------------------------------------------------------------

function add_common_options()
{
  config_options+=("--prefix=${APP_PREFIX}")
  config_options+=("--libdir=${APP_PREFIX}/lib")
  config_options+=("--with-local-prefix=${APP_PREFIX}/local")

  config_options+=("--build=${BUILD}")
  config_options+=("--host=${HOST}")
  config_options+=("--target=${TARGET}")

  config_options+=("--program-suffix=")
  config_options+=("--with-pkgversion=${BRANDING}")

  config_options+=("--with-dwarf2")
  config_options+=("--with-tune=generic")
  config_options+=("--with-libiconv")
  config_options+=("--with-isl")
  config_options+=("--with-system-zlib")
  config_options+=("--with-gnu-as")
  config_options+=("--with-gnu-ld")

  config_options+=("--enable-checking=release")
  config_options+=("--enable-threads=posix")
  config_options+=("--enable-linker-build-id")

  config_options+=("--enable-lto")
  config_options+=("--enable-plugin")

  config_options+=("--enable-shared")
  config_options+=("--enable-shared-libgcc")
  config_options+=("--enable-static")

  config_options+=("--enable-__cxa_atexit")

  # Tells GCC to use the gnu_unique_object relocation for C++ 
  # template static data members and inline function local statics.
  config_options+=("--enable-gnu-unique-object")
  config_options+=("--enable-gnu-indirect-function")

  config_options+=("--enable-default-pie")
  config_options+=("--enable-default-ssp")

  config_options+=("--enable-fully-dynamic-string")
  config_options+=("--enable-libstdcxx-time=yes")
  config_options+=("--enable-cloog-backend=isl")
  config_options+=("--enable-libgomp")

  config_options+=("--enable-libatomic")
  config_options+=("--enable-graphite")
  config_options+=("--enable-libquadmath")
  config_options+=("--enable-libquadmath-support")

  config_options+=("--disable-multilib")
  config_options+=("--disable-libstdcxx-pch")
  config_options+=("--disable-libstdcxx-debug")

  config_options+=("--disable-nls")
  config_options+=("--disable-werror")

  config_options+=("--disable-bootstrap")
}

# -----------------------------------------------------------------------------

function do_native_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://gcc.gnu.org/install

  # https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@8.rb

  # 2018-12-06, "7.4.0"
  # 2019-11-14, "7.5.0"
  # 2019-02-22, "8.3.0"
  # 2019-08-12, "9.2.0"

  local native_gcc_version="$1"
  
  local native_gcc_src_folder_name="gcc-${native_gcc_version}"
  local native_gcc_folder_name="native-gcc-${native_gcc_version}"

  local native_gcc_archive="${native_gcc_src_folder_name}.tar.xz"
  local native_gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${native_gcc_version}/${native_gcc_archive}"

  WITH_GLIBC=${WITH_GLIBC:=""}

  local native_gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${native_gcc_folder_name}-installed"
  if [ ! -f "${native_gcc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${native_gcc_url}" "${native_gcc_archive}" "${native_gcc_src_folder_name}" 

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${native_gcc_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${native_gcc_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${native_gcc_src_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CPPFLAGS_FOR_TARGET="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS} -Wno-error -Wno-sign-compare -Wno-varargs -Wno-tautological-compare -Wno-format-security -Wno-enum-compare -Wno-abi -Wno-stringop-truncation -Wno-unused-function -Wno-incompatible-pointer-types -Wno-format-truncation -Wno-implicit-fallthrough"
      CXXFLAGS="${XBB_CXXFLAGS} -Wno-error -Wno-sign-compare -Wno-varargs -Wno-tautological-compare -Wno-format -Wno-abi -Wno-type-limits -Wno-deprecated-copy"
      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP} -v"

      if [[ "${CC}" =~ clang* ]]
      then
        CFLAGS+=" -Wno-mismatched-tags -Wno-array-bounds -Wno-null-conversion -Wno-extended-offsetof -Wno-c99-extensions -Wno-keyword-macro -Wno-unused-function" 
        CXXFLAGS+=" -Wno-mismatched-tags -Wno-array-bounds -Wno-null-conversion -Wno-extended-offsetof -Wno-keyword-macro -Wno-unused-function" 
      elif [[ "${CC}" =~ gcc* ]]
      then
        CFLAGS+=" -Wno-cast-function-type -Wno-maybe-uninitialized"
        CXXFLAGS+=" -Wno-cast-function-type -Wno-maybe-uninitialized"
      fi

      export CPPFLAGS
      export CPPFLAGS_FOR_TARGET
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running native gcc configure..."

          bash "${SOURCES_FOLDER_PATH}/${native_gcc_src_folder_name}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${native_gcc_src_folder_name}/gcc/configure" --help

          config_options=()

          add_common_options

          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then

            local print_path="$(xcode-select -print-path)"
            if [ -d "${print_path}/SDKs/MacOSX.sdk" ]
            then
              # Without Xcode, use the SDK that comes with the CLT.
              MACOS_SDK_PATH="${print_path}/SDKs/MacOSX.sdk"
            elif [ -d "${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" ]
            then
              # With Xcode, chose the SDK from the macOS platform.
              MACOS_SDK_PATH="${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
            elif [ -d "/usr/include" ]
            then
              # Without Xcode, on 10.10 there is no SDK, use the root.
              MACOS_SDK_PATH="/"
            else
              echo "Cannot find SDK in ${print_path}."
              exit 1
            fi

            # Fail on macOS
            # --with-linker-hash-style=gnu 
            # --enable-libmpx 
            # --enable-clocale=gnu
            echo "${MACOS_SDK_PATH}"

            # From HomeBrew
            config_options+=("--with-sysroot=${MACOS_SDK_PATH}")
            config_options+=("--with-native-system-header-dir=/usr/include")

            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")            

          else [ "${TARGET_PLATFORM}" == "linux" ]

            # The Linux build also uses:
            # --with-linker-hash-style=gnu
            # --enable-libmpx (fails on arm)
            # --enable-clocale=gnu 
            # --enable-install-libiberty 

            # Ubuntu also used:
            # --enable-libstdcxx-debug 
            # --enable-libstdcxx-time=yes (links librt)
            # --with-default-libstdcxx-abi=new (default)

            if [ "${TARGET_ARCH}" == "x64" ]
            then
              config_options+=("--with-arch=x86-64")
            elif [ "${TARGET_ARCH}" == "x32" ]
            then
              config_options+=("--with-arch=i686")
            elif [ "${TARGET_ARCH}" == "aarch64" ]
            then
              config_options+=("--with-arch=armv8-a")
              config_options+=("--enable-fix-cortex-a53-835769")
              config_options+=("--enable-fix-cortex-a53-843419")
            elif [ "${TARGET_ARCH}" == "armv7l" -o "${TARGET_ARCH}" == "armv8l" ]
            then
              config_options+=("--with-arch=armv7-a")
              config_options+=("--with-float=hard")
              config_options+=("--with-fpu=vfpv3-d16")
            fi

            # config_options+=("--enable-languages=c,c++,fortran")
            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")

            # Used by Arch
            config_options+=("--disable-libunwind-exceptions")
            config_options+=("--disable-libssp")
            config_options+=("--with-linker-hash-style=gnu")
            config_options+=("--enable-clocale=gnu")

            if [ "${WITH_GLIBC}" == "y" ]
            then
              config_options+=("--with-local-prefix=${APP_PREFIX}/usr")
              config_options+=("--with-sysroot=${APP_PREFIX}")
              config_options+=("--with-build-sysroot=/")
              # config_options+=("--with-native-system-header-dir=/usr/include")
            fi

          fi

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${native_gcc_src_folder_name}/configure" \
            ${config_options[@]}
              
          cp "config.log" "${LOGS_FOLDER_PATH}/${native_gcc_src_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${native_gcc_src_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running native gcc make..."

        # Build.
        if [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          # From HomeBrew
          export BOOT_LDFLAGS="-Wl,-headerpad_max_install_names"
        fi
        make -j ${JOBS}

        make install-strip

        show_libs "${APP_PREFIX}/bin/gcc"
        show_libs "${APP_PREFIX}/bin/g++"

        show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1)"
        show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1plus)"
        show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=collect2)"
        show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto1)"
        show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto-wrapper)"

        (
          xbb_activate_tex

          # Full build, with documentation.
          if [ "${WITH_PDF}" == "y" ]
          then
            make pdf
            make install-pdf
          fi

          if [ "${WITH_HTML}" == "y" ]
          then
            make html
            make install-html
          fi
        )

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${native_gcc_src_folder_name}/make-output.txt"
    )

    touch "${native_gcc_stamp_file_path}"

  else
    echo "Component native gcc already installed."
  fi
}

# -----------------------------------------------------------------------------

function do_native_gcc_test()
{
  echo
  echo "Testing the native gcc binaries..."

  (
    # Without it, the old /usr/bin/ld fails.
    xbb_activate

    xbb_activate_installed_bin

    echo
    run_app "${APP_PREFIX}/bin/g++" --version
    run_app "${APP_PREFIX}/bin/g++" -dumpmachine
    run_app "${APP_PREFIX}/bin/g++" -print-search-dirs
    run_app "${APP_PREFIX}/bin/g++" -dumpspecs | wc -l

    mkdir -p "${HOME}/tmp"
    cd "${HOME}/tmp"

    # Note: __EOF__ is quoted to prevent substitutions here.
    cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;
}
__EOF__

    if true
    then

      "${APP_PREFIX}/bin/g++" hello.cpp -o hello -v

      if [ "x$(./hello)x" != "xHellox" ]
      then
        exit 1
      fi

    fi

    rm -rf hello.cpp hello
  )

  echo
  echo "Local native gcc tests completed successfuly."
}

function do_test()
{
  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    : # do_mingw "" ""
  else
    do_native_gcc_test 
  fi
}

function strip_libs()
{
  if [ "${WITH_STRIP}" == "y" ]
  then
    (
      xbb_activate

      PATH="${APP_PREFIX}/bin:${PATH}"

      echo
      echo "Stripping libraries..."

      cd "${WORK_FOLDER_PATH}"

      # which "${GCC_TARGET}-objcopy"

      local libs=$(find "${APP_PREFIX}" -name '*.[ao]')
      for lib in ${libs}
      do
        echo "strip -S ${lib}"
        strip -S ${lib}
      done
    )
  fi
}

# -----------------------------------------------------------------------------
