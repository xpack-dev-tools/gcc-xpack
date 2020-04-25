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

function do_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://gcc.gnu.org/install

  # https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@8.rb

  # Mingw
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD 
  # https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD


  # 2018-10-30, "6.5.0"
  # 2018-12-06, "7.4.0"
  # 2019-11-14, "7.5.0"
  # 2018-05-02, "8.1.0"
  # 2018-07-26, "8.2.0"
  # 2019-02-22, "8.3.0"
  # 2020-03-04, "8.4.0"
  # 2019-05-03, "9.1.0"
  # 2019-08-12, "9.2.0"
  # 2020-03-12, "9.3.0"

  local gcc_version="$1"

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  local gcc_src_folder_name="gcc-${gcc_version}"
  local gcc_folder_name="${gcc_src_folder_name}"

  local gcc_archive="${gcc_src_folder_name}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"

  WITH_GLIBC=${WITH_GLIBC:=""}

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${gcc_folder_name}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" "${gcc_src_folder_name}" 

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gcc_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CPPFLAGS_FOR_TARGET="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      if [[ "${CC}" =~ *clang* ]]
      then
        CFLAGS+=" -Wno-mismatched-tags -Wno-array-bounds -Wno-null-conversion -Wno-extended-offsetof -Wno-c99-extensions -Wno-keyword-macro -Wno-unused-function" 
        CXXFLAGS+=" -Wno-mismatched-tags -Wno-array-bounds -Wno-null-conversion -Wno-extended-offsetof -Wno-keyword-macro -Wno-unused-function" 
      elif [[ "${CC}" =~ *gcc* ]]
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
          echo "Running gcc configure..."

          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/gcc/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")
          config_options+=("--libdir=${APP_PREFIX}/lib")
          config_options+=("--with-local-prefix=${APP_PREFIX}/local")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--program-suffix=")
          config_options+=("--with-pkgversion=${GCC_BRANDING}")

          config_options+=("--with-dwarf2")
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
          config_options+=("--enable-libssp")
         
          config_options+=("--enable-libatomic")
          config_options+=("--enable-graphite")
          config_options+=("--enable-libquadmath")
          config_options+=("--enable-libquadmath-support")

          config_options+=("--disable-multilib")
          config_options+=("--disable-libstdcxx-pch")
          config_options+=("--disable-libstdcxx-debug")

          # config_options+=("--disable-nls")
          config_options+=("--disable-werror")

          config_options+=("--disable-bootstrap")

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

          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then

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
              config_options+=("--with-tune=generic")
            elif [ "${TARGET_ARCH}" == "x32" ]
            then
              config_options+=("--with-arch=i686")
              config_options+=("--with-tune=generic")
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
            else
              echo "Unsupported ${TARGET_ARCH}"
              exit 1
            fi

            # config_options+=("--enable-languages=c,c++,fortran")
            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")

            # Used by Arch
            # config_options+=("--disable-libunwind-exceptions")
            # config_options+=("--disable-libssp")
            config_options+=("--with-linker-hash-style=gnu")
            config_options+=("--enable-clocale=gnu")

            if [ "${WITH_GLIBC}" == "y" ]
            then
              config_options+=("--with-local-prefix=${APP_PREFIX}/usr")
              config_options+=("--with-sysroot=${APP_PREFIX}")
              config_options+=("--with-build-sysroot=/")
              # config_options+=("--with-native-system-header-dir=/usr/include")
            fi

          elif [ "${TARGET_PLATFORM}" == "win32" ]
          then

            # config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")
            # x86_64-w64-mingw32-gcc: error: /Host/home/ilg/Work/gcc-8.4.0-1/sources/gcc-8.4.0/libobjc/NXConstStr.m: Objective-C compiler not installed on this system
            # checking whether the GNU Fortran compiler is working... no
            config_options+=("--enable-languages=c,c++,lto")

            # Inspired from mingw-w64; no --with-sysroot
            config_options+=("--with-native-system-header-dir=${APP_PREFIX}/include")

            # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
            # The defaults are sjlj for 32-bit and seh for 64-bit, thus
            # better do not set anything explicitly, since disabling sjlj
            # fails on 64-bit:
            # error: ‘__LIBGCC_EH_FRAME_SECTION_NAME__’ undeclared here
            # config_options+=("--disable-sjlj-exceptions")
            # Arch also uses --disable-dw2-exceptions

            if [ "${TARGET_ARCH}" == "x64" ]
            then
              config_options+=("--with-arch=x86-64")
            elif [ "${TARGET_ARCH}" == "x32" ]
            then
              config_options+=("--with-arch=i686")
            else
              echo "Unsupported ${TARGET_ARCH}"
              exit 1
            fi

            if [ ${MINGW_VERSION_MAJOR} -ge 7 -a ${gcc_version_major} -ge 9 ]
            then
              # Requires at least GCC 9 & mingw 7.
              config_options+=("--enable-libstdcxx-filesystem-ts=yes")
            fi

            config_options+=("--disable-rpath")
            # Disable look up installations paths in the registry.
            config_options+=("--disable-win32-registry")
            # Turn on symbol versioning in the shared library
            config_options+=("--disable-symvers")

          else
            echo "Unsupported ${TARGET_PLATFORM}"
            exit 1
          fi

          echo ${config_options[@]}

          gcc --version
          cc --version

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/configure" \
            ${config_options[@]}
              
          cp "config.log" "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running gcc make..."

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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}/make-output.txt"
    )

    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc already installed."
  fi
}

# -----------------------------------------------------------------------------

function do_mingw() 
{
  # http://mingw-w64.org/doku.php/start
  # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-headers
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-crt
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-winpthreads
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-headers-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-crt-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-winpthreads-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD
  
  # https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD


  # 2018-06-03, "5.0.4"
  # 2018-09-16, "6.0.0"
  # 2019-11-11, "7.0.0"

  MINGW_VERSION="$1"

  # Number
  MINGW_VERSION_MAJOR=$(echo ${MINGW_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  # The original SourceForge location.
  local mingw_src_folder_name="mingw-w64-v${MINGW_VERSION}"
  local mingw_folder_name="${mingw_src_folder_name}"

  local mingw_archive="${mingw_folder_name}.tar.bz2"
  local mingw_url="https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/${mingw_archive}"
  
  # If SourceForge is down, there is also a GitHub mirror.
  # https://github.com/mirror/mingw-w64
  # mingw_folder_name="mingw-w64-${MINGW_VERSION}"
  # mingw_archive="v${MINGW_VERSION}.tar.gz"
  # mingw_url="https://github.com/mirror/mingw-w64/archive/${mingw_archive}"
 
  # https://sourceforge.net/p/mingw-w64/wiki2/Cross%20Win32%20and%20Win64%20compiler/
  # https://sourceforge.net/p/mingw-w64/mingw-w64/ci/master/tree/configure

  # ---------------------------------------------------------------------------

  # The 'headers' step creates the 'include' folder.

  local mingw_headers_folder_name="mingw-${MINGW_VERSION}-headers"

  cd "${SOURCES_FOLDER_PATH}"

  download_and_extract "${mingw_url}" "${mingw_archive}" "${mingw_src_folder_name}"

  local mingw_headers_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${mingw_headers_folder_name}-installed"
  if [ ! -f "${mingw_headers_stamp_file_path}" ]
  then
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${mingw_headers_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${mingw_headers_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${mingw_folder_name}"

      xbb_activate

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mingw-w64 headers configure..."

          bash "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-headers/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")
                        
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--with-tune=generic")

          # From mingw-w64-headers
          config_options+=("--enable-sdk=all")
          config_options+=("--with-default-win32-winnt=0x601")
          config_options+=("--enable-idl")
          config_options+=("--without-widl")

          # From Arch
          config_options+=("--enable-secure-api")

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-headers/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${mingw_folder_name}/config-headers-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/configure-headers-output.txt"
      fi

      (
        echo
        echo "Running mingw-w64 headers make..."

        # Build.
        make -j ${JOBS}

        make install-strip

        # From mingw-w64 and Arch
        rm -fv "${APP_PREFIX}/include/pthread_signal.h"
        rm -fv "${APP_PREFIX}/include/pthread_time.h"
        rm -fv "${APP_PREFIX}/include/pthread_unistd.h"

        echo
        echo "${APP_PREFIX}/include"
        ls -l "${APP_PREFIX}/include" 

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/make-headers-output.txt"

      # No need to do it again.
      copy_license \
        "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}" \
        "${mingw_folder_name}"

    )

    touch "${mingw_headers_stamp_file_path}"

  else
    echo "Component mingw-w64 headers already installed."
  fi

  # ---------------------------------------------------------------------------

  # The 'crt' step creates the C run-time in the 'lib' folder.

  local mingw_crt_folder_name="mingw-${MINGW_VERSION}-crt"

  local mingw_crt_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${mingw_crt_folder_name}-installed"
  if [ ! -f "${mingw_crt_stamp_file_path}" ]
  then
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${mingw_crt_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${mingw_crt_folder_name}"

      xbb_activate
      # xbb_activate_installed_bin

      # Overwrite the flags, -ffunction-sections -fdata-sections result in
      # {standard input}: Assembler messages:
      # {standard input}:693: Error: CFI instruction used without previous .cfi_startproc
      # {standard input}:695: Error: .cfi_endproc without corresponding .cfi_startproc
      # {standard input}:697: Error: .seh_endproc used in segment '.text' instead of expected '.text$WinMainCRTStartup'
      # {standard input}: Error: open CFI at the end of file; missing .cfi_endproc directive
      # {standard input}:7150: Error: can't resolve `.text' {.text section} - `.LFB5156' {.text$WinMainCRTStartup section}
      # {standard input}:8937: Error: can't resolve `.text' {.text section} - `.LFB5156' {.text$WinMainCRTStartup section}

      export CPPFLAGS=""
      export CFLAGS="-O2 -pipe -w"
      export CXXFLAGS="-O2 -pipe -w"
      export LDFLAGS="-v"
      
      # Without it, apparently a bug in autoconf/c.m4, function AC_PROG_CC, results in:
      # checking for _mingw_mac.h... no
      # configure: error: Please check if the mingw-w64 header set and the build/host option are set properly.
      # (https://github.com/henry0312/build_gcc/issues/1)
      # export CC=""

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mingw-w64 crt configure..."

          bash "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-crt/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")
                        
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          if [ "${TARGET_ARCH}" == "x64" ]
          then
            config_options+=("--disable-lib32")
            config_options+=("--enable-lib64")
          elif [ "${TARGET_ARCH}" == "x32" ]
          then
            config_options+=("--enable-lib32")
            config_options+=("--disable-lib64")
          else
            exit 1
          fi

          config_options+=("--with-sysroot=${APP_PREFIX}")
          config_options+=("--enable-wildcard")

          config_options+=("--enable-warnings=0")

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-crt/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${mingw_folder_name}/config-crt-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/configure-crt-output.txt"
      fi

      (
        echo
        echo "Running mingw-w64 crt make..."

        # Build.
        make -j ${JOBS}

        make install-strip

        echo
        echo "${APP_PREFIX}/lib"
        ls -l "${APP_PREFIX}/lib" 

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/make-crt-output.txt"
    )

    touch "${mingw_crt_stamp_file_path}"

  else
    echo "Component mingw-w64 crt already installed."
  fi

  # ---------------------------------------------------------------------------  

  local mingw_winpthreads_folder_name="mingw-${MINGW_VERSION}-winpthreads"

  local mingw_winpthreads_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${mingw_winpthreads_folder_name}-installed"
  if [ ! -f "${mingw_winpthreads_stamp_file_path}" ]
  then

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${mingw_winpthreads_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${mingw_winpthreads_folder_name}"

      xbb_activate
      xbb_activate_installed_bin

      export CPPFLAGS="" 
      export CFLAGS="-O2 -pipe -w"
      export CXXFLAGS="-O2 -pipe -w"
      export LDFLAGS="-v"
      
      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running mingw-w64 winpthreads configure..."

          bash "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-libraries/winpthreads/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")
                        
          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--with-sysroot=${APP_PREFIX}")

          config_options+=("--enable-static")
          config_options+=("--enable-shared")

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${mingw_src_folder_name}/mingw-w64-libraries/winpthreads/configure" \
            ${config_options[@]}

         cp "config.log" "${LOGS_FOLDER_PATH}/${mingw_folder_name}/config-winpthreads-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/configure-winpthreads-output.txt"
      fi
      
      (
        echo
        echo "Running mingw-w64 winpthreads make..."

        # Build.
        make -j ${JOBS}

        make install-strip

        echo
        echo "${APP_PREFIX}/lib"
        ls -l "${APP_PREFIX}/lib"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${mingw_folder_name}/make-winpthreads-output.txt"
    )

    touch "${mingw_winpthreads_stamp_file_path}"

  else
    echo "Component mingw-w64 winpthreads already installed."
  fi

  # ---------------------------------------------------------------------------
}

# -----------------------------------------------------------------------------

function do_test()
{
  echo
  echo "Testing the gcc binaries..."

  (
    # Without it, the old /usr/bin/ld fails.
    xbb_activate

    xbb_activate_installed_bin

    echo
    echo "Testing if gcc starts properly..."

    run_app "${APP_PREFIX}/bin/g++" --version
    run_app "${APP_PREFIX}/bin/g++" -dumpversion
    run_app "${APP_PREFIX}/bin/g++" -dumpmachine
    run_app "${APP_PREFIX}/bin/g++" -print-multi-lib
    run_app "${APP_PREFIX}/bin/g++" -print-search-dirs
    run_app "${APP_PREFIX}/bin/g++" -dumpspecs | wc -l

    # Cannot run the the compiler without a loader.
    if [ "${TARGET_PLATFORM}" != "win32" ]
    then

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

      # Test C compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/gcc" -o hello-c.o -c hello.c
      run_app "${APP_PREFIX}/bin/gcc" -o hello-c2 hello-c.o
      show_libs hello-c2

      if [ "x$(./hello-c2)x" == "xHellox" ]
      then
        echo "hello-c2 ok"
      else
        exit 1
      fi

      # Test LTO C compile and link in a single step.
      run_app "${APP_PREFIX}/bin/gcc" -flto -o lto-hello-c1 hello.c
      show_libs lto-hello-c1

      if [ "x$(./lto-hello-c1)x" == "xHellox" ]
      then
        echo "lto-hello-c1 ok"
      else
        exit 1
      fi

      # Test LTO C compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/gcc" -flto -o lto-hello-c.o -c hello.c
      run_app "${APP_PREFIX}/bin/gcc" -flto -o lto-hello-c2 lto-hello-c.o
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
      run_app "${APP_PREFIX}/bin/g++" -o hello-cpp1 hello.cpp
      show_libs hello-cpp1

      if [ "x$(./hello-cpp1)x" == "xHellox" ]
      then
        echo "hello-cpp1 ok"
      else
        exit 1
      fi

      # Test C++ compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/g++" -o hello-cpp.o -c hello.cpp
      run_app "${APP_PREFIX}/bin/g++" -o hello-cpp2 hello-cpp.o
      show_libs hello-cpp2

      if [ "x$(./hello-cpp2)x" == "xHellox" ]
      then
        echo "hello-cpp2 ok"
      else
        exit 1
      fi

      # Test LTO C++ compile and link in a single step.
      run_app "${APP_PREFIX}/bin/g++" -flto -o lto-hello-cpp1 hello.cpp
      show_libs lto-hello-cpp1

      if [ "x$(./lto-hello-cpp1)x" == "xHellox" ]
      then
        echo "lto-hello-cpp1 ok"
      else
        exit 1
      fi

      # Test LTO C++ compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/g++" -flto -o lto-hello-cpp.o -c hello.cpp
      run_app "${APP_PREFIX}/bin/g++" -flto  -o lto-hello-cpp2 lto-hello-cpp.o
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
      run_app "${APP_PREFIX}/bin/g++" -o except -O0 except.cpp
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
      run_app "${APP_PREFIX}/bin/g++" -o str-except -O0 str-except.cpp
      show_libs str-except

      if [ "x$(./str-except)x" == "xMyStringExceptionx" ]
      then
        echo "str-except ok"
      else
        exit 1
      fi

    fi
  )

  echo
  echo "Local gcc tests completed successfuly."
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

      # which "objcopy"

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
