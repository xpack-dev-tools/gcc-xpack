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

# Separate step to be executed before building binutils, to allow the
# reuse of the contrib/download_prerequisites script.

function download_gcc()
{
  local gcc_version="$1"

  # Branch from the Darwin maintainer of GCC with Apple Silicon support,
  # located at https://github.com/iains/gcc-darwin-arm64 and
  # backported with his help to gcc-11 branch. Too big for a patch.
  # The repo used by the HomeBrew:
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/fxcoudert/gcc/tags
  if [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "11.2.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.2.0-arm-20211201.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.2.0-arm-20211201"
    local gcc_archive="gcc-11.2.0-arm-20211201.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  elif [ "${TARGET_PLATFORM}" == "darwin" -a "${TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "11.1.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.1.0-arm-20210504.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.1.0-arm-20210504"
    local gcc_archive="gcc-11.1.0-arm-20210504.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  else
    export GCC_SRC_FOLDER_NAME="gcc-${gcc_version}"

    local gcc_archive="${GCC_SRC_FOLDER_NAME}.tar.xz"
    local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"
    local gcc_patch_file_name="gcc-${gcc_version}.patch.diff"
  fi

  mkdir -pv "${LOGS_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}"

  local gcc_download_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_SRC_FOLDER_NAME}-downloaded"
  if [ ! -f "${gcc_download_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" \
      "${GCC_SRC_FOLDER_NAME}" "${gcc_patch_file_name}"

    local gcc_prerequisites_download_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_SRC_FOLDER_NAME}-prerequisites-downloaded"
    if false # [ ! -f "${gcc_prerequisites_download_stamp_file_path}" ]
    then
      (
        cd "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}"

        run_verbose bash "contrib/download_prerequisites"

        touch "${gcc_prerequisites_download_stamp_file_path}"
      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/prerequisites-download-output-$(ndate).txt"
    fi

    touch "${gcc_download_stamp_file_path}"
  fi
}

function build_gcc()
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://gcc.gnu.org/install
  # https://gcc.gnu.org/install/configure.html

  # https://github.com/archlinux/svntogit-community/blob/packages/gcc10/trunk/PKGBUILD
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD

  # https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@8.rb

  # Mingw on Arch
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-headers/trunk/PKGBUILD
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-crt/trunk/PKGBUILD
  #
  # Mingw on Msys2
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD
  # https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD


  # 2018-05-02, "8.1.0"
  # 2018-07-26, "8.2.0"
  # 2018-10-30, "6.5.0" *
  # 2018-12-06, "7.4.0"
  # 2019-02-22, "8.3.0"
  # 2019-05-03, "9.1.0"
  # 2019-08-12, "9.2.0"
  # 2019-11-14, "7.5.0" *
  # 2020-03-04, "8.4.0"
  # 2020-03-12, "9.3.0"
  # 2021-04-08, "10.3.0"
  # 2021-04-27, "11.1.0" +
  # 2021-05-14, "8.5.0" *
  # 2021-07-28, "11.2.0"

  local gcc_version="$1"
  local name_suffix=${2-''}

  if [ -n "${name_suffix}" -a "${TARGET_PLATFORM}" != "win32" ]
  then
    echo "Native supported only for Windows binaries."
    exit 1
  fi

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  export GCC_FOLDER_NAME="${GCC_SRC_FOLDER_NAME}${name_suffix}"

  mkdir -pv "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      if [ -n "${name_suffix}" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS} -I${LIBS_INSTALL_FOLDER_PATH}${name_suffix}/include"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      else

        # To access the newly compiled libraries.
        # On Arm it still needs --with-gmp
        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
        LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"

        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          if [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
          then
            # From MSYS2 MINGW
            LDFLAGS+=" -Wl,--large-address-aware"
          fi
          # From MSYS2, but not supported by GCC 9
          # LDFLAGS+=" -Wl,--disable-dynamicbase"

          # Used to enable wildcard; inspired from arm-none-eabi-gcc.
          # LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/lib/CRT_glob.o"
        elif [ "${TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH:-${LIBS_INSTALL_FOLDER_PATH}/lib}"

          export LDFLAGS_FOR_TARGET="${LDFLAGS}"
          export LDFLAGS_FOR_BUILD="${LDFLAGS}"
          export BOOT_LDFLAGS="${LDFLAGS}"
        elif [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          :
        else
          echo "Oops! Unsupported ${TARGET_PLATFORM}."
          exit 1
        fi
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running gcc${name_suffix} configure..."

          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/gcc/configure" --help

          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libgcc/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libstdc++-v3/configure" --help

          config_options=()

          if [ -n "${name_suffix}" ]
          then

            # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc-base

            config_options+=("--prefix=${APP_PREFIX}${name_suffix}")
            config_options+=("--with-sysroot=${APP_PREFIX}${name_suffix}")

            config_options+=("--build=${BUILD}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${BUILD}")
            config_options+=("--target=${TARGET}")

            config_options+=("--with-pkgversion=${GCC_BOOTSTRAP_BRANDING}")

            config_options+=("--with-gmp=${LIBS_INSTALL_FOLDER_PATH}${name_suffix}")

            # config_options+=("--with-default-libstdcxx-abi=gcc4-compatible")
            config_options+=("--with-default-libstdcxx-abi=new")

            config_options+=("--with-dwarf2")

            config_options+=("--disable-multilib")
            config_options+=("--disable-werror")

            # To simplify things, especially tests, the
            # bootstrap can be static.
            config_options+=("--disable-shared")
            config_options+=("--disable-shared-libgcc")

            config_options+=("--disable-nls")
            config_options+=("--disable-libgomp")

            config_options+=("--disable-sjlj-exceptions")
            config_options+=("--disable-libunwind-exceptions")
            config_options+=("--disable-win32-registry")
            config_options+=("--disable-libstdcxx-debug")
            config_options+=("--disable-libstdcxx-pch")

            config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")
            config_options+=("--enable-objc-gc=auto")

            config_options+=("--enable-static")

            # config_options+=("--enable-fully-dynamic-string")
            config_options+=("--enable-lto")
            # hello-tls.c:(.text+0x14): undefined reference to `tlsvar@ntpoff'
            # config_options+=("--enable-tls")
            config_options+=("--enable-checking=release")

            config_options+=("--enable-cloog-backend=isl")
            #  the GNU Offloading and Multi Processing Runtime Library
            config_options+=("--enable-libssp")
            config_options+=("--enable-libatomic")
            # config_options+=("--enable-graphite")
            # config_options+=("--enable-libquadmath")
            # config_options+=("--enable-libquadmath-support")
            config_options+=("--enable-__cxa_atexit")
            config_options+=("--enable-mingw-wildcard")
            # config_options+=("--enable-large-address-aware")

            config_options+=("--enable-version-specific-runtime-libs")
            config_options+=("--enable-threads=posix")

            config_options+=("--enable-libstdcxx")
            config_options+=("--enable-libstdcxx-time=yes")
            config_options+=("--enable-libstdcxx-visibility")
            config_options+=("--enable-libstdcxx-threads")

          else

            config_options+=("--prefix=${APP_PREFIX}${name_suffix}")
            config_options+=("--program-suffix=")

            config_options+=("--infodir=${APP_PREFIX_DOC}/info")
            config_options+=("--mandir=${APP_PREFIX_DOC}/man")
            config_options+=("--htmldir=${APP_PREFIX_DOC}/html")
            config_options+=("--pdfdir=${APP_PREFIX_DOC}/pdf")

            config_options+=("--build=${BUILD}")
            config_options+=("--host=${HOST}")
            config_options+=("--target=${TARGET}")

            config_options+=("--with-pkgversion=${GCC_BRANDING}")

            if [ "${TARGET_PLATFORM}" != "linux" ]
            then
              config_options+=("--with-libiconv-prefix=${LIBS_INSTALL_FOLDER_PATH}")
            fi

            config_options+=("--with-dwarf2")
            config_options+=("--with-libiconv")
            config_options+=("--with-isl")
            config_options+=("--with-diagnostics-color=auto")

            config_options+=("--with-gmp=${LIBS_INSTALL_FOLDER_PATH}${name_suffix}")

            config_options+=("--without-system-zlib")
            config_options+=("--without-cuda-driver")

            config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")
            config_options+=("--enable-objc-gc=auto")

            # Intel specific.
            # config_options+=("--enable-cet=auto")
            config_options+=("--enable-checking=release")

            config_options+=("--enable-lto")
            config_options+=("--enable-plugin")

            config_options+=("--enable-static")

            config_options+=("--enable-__cxa_atexit")

            config_options+=("--enable-threads=posix")

            # It fails on macOS master with:
            # libstdc++-v3/include/bits/cow_string.h:630:9: error: no matching function for call to 'std::basic_string<wchar_t>::_Alloc_hider::_Alloc_hider(std::basic_string<wchar_t>::_Rep*)'
            # config_options+=("--enable-fully-dynamic-string")
            config_options+=("--enable-cloog-backend=isl")

            # The GNU Offloading and Multi Processing Runtime Library
            config_options+=("--enable-libgomp")

            config_options+=("--enable-libssp")
            config_options+=("--enable-default-ssp")
            config_options+=("--enable-libatomic")
            config_options+=("--enable-graphite")
            config_options+=("--enable-libquadmath")
            config_options+=("--enable-libquadmath-support")

            config_options+=("--enable-libstdcxx")
            config_options+=("--enable-libstdcxx-time=yes")
            config_options+=("--enable-libstdcxx-visibility")
            config_options+=("--enable-libstdcxx-threads")
            config_options+=("--with-default-libstdcxx-abi=new")

            config_options+=("--enable-pie-tools")

            # config_options+=("--enable-version-specific-runtime-libs")

            # TODO
            # config_options+=("--enable-nls")
            config_options+=("--disable-nls")

            config_options+=("--disable-multilib")
            config_options+=("--disable-libstdcxx-debug")
            config_options+=("--disable-libstdcxx-pch")

            config_options+=("--disable-install-libiberty")

            # It is not yet clear why, but Arch, RH use it.
            # config_options+=("--disable-libunwind-exceptions")

            config_options+=("--disable-werror")

            if [ "${TARGET_PLATFORM}" == "darwin" ]
            then

              # DO NOT DISABLE, otherwise 'ld: library not found for -lgcc_ext.10.5'.
              config_options+=("--enable-shared")
              config_options+=("--enable-shared-libgcc")

              # This distribution expects the SDK to be installed
              # with the Command Line Tools, which have a fixed location,
              # while Xcode may vary from version to version.
              config_options+=("--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk")

              # From HomeBrew, but not present on 11.x
              # config_options+=("--with-native-system-header-dir=/usr/include")

              config_options+=("--enable-default-pie")

              if [ "${IS_DEVELOP}" == "y" ]
              then
                # To speed things up during development.
                config_options+=("--disable-bootstrap")
              else
                config_options+=("--enable-bootstrap")
              fi

            elif [ "${TARGET_PLATFORM}" == "linux" ]
            then

              # Shared libraries remain problematic when refered from generated
              # programs, and require setting the executable rpath to work.
              config_options+=("--enable-shared")
              config_options+=("--enable-shared-libgcc")

              if [ "${IS_DEVELOP}" == "y" ]
              then
                config_options+=("--disable-bootstrap")
              else
                config_options+=("--enable-bootstrap")
              fi

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
                # Support for Intel Memory Protection Extensions (MPX).
                config_options+=("--enable-libmpx")
              elif [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
              then
                config_options+=("--with-arch=i686")
                config_options+=("--with-arch-32=i686")
                config_options+=("--with-tune=generic")
                config_options+=("--enable-libmpx")
              elif [ "${TARGET_ARCH}" == "arm64" ]
              then
                config_options+=("--with-arch=armv8-a")
                config_options+=("--enable-fix-cortex-a53-835769")
                config_options+=("--enable-fix-cortex-a53-843419")
              elif [ "${TARGET_ARCH}" == "arm" ]
              then
                config_options+=("--with-arch=armv7-a")
                config_options+=("--with-float=hard")
                config_options+=("--with-fpu=vfpv3-d16")
              else
                echo "Oops! Unsupported ${TARGET_ARCH}."
                exit 1
              fi

              config_options+=("--with-pic")

              config_options+=("--with-stabs")
              config_options+=("--with-gnu-as")
              config_options+=("--with-gnu-ld")

              # Used by Arch
              # config_options+=("--disable-libunwind-exceptions")
              # config_options+=("--disable-libssp")
              config_options+=("--with-linker-hash-style=gnu")
              config_options+=("--enable-clocale=gnu")

              config_options+=("--enable-default-pie")

              # Tells GCC to use the gnu_unique_object relocation for C++
              # template static data members and inline function local statics.
              config_options+=("--enable-gnu-unique-object")
              config_options+=("--enable-gnu-indirect-function")
              config_options+=("--enable-linker-build-id")

              # Not needed.
              # config_options+=("--with-sysroot=${APP_PREFIX}")
              # config_options+=("--with-native-system-header-dir=/usr/include")

            elif [ "${TARGET_PLATFORM}" == "win32" ]
            then

              # With shared 32-bit, the simple-exception and other
              # tests with exceptions, fail.
              config_options+=("--disable-shared")
              config_options+=("--disable-shared-libgcc")

              if [ "${TARGET_ARCH}" == "x64" ]
              then
                config_options+=("--with-arch=x86-64")
              elif [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
              then
                config_options+=("--with-arch=i686")

                # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
                # The defaults are sjlj for 32-bit and seh for 64-bit,
                # So better disable SJLJ explicitly.
                config_options+=("--disable-sjlj-exceptions")
              else
                echo "Oops! Unsupported ${TARGET_ARCH}."
                exit 1
              fi

              # Cross builds have their own explicit bootstrap.
              config_options+=("--disable-bootstrap")

              config_options+=("--enable-mingw-wildcard")

              # Tells GCC to use the gnu_unique_object relocation for C++
              # template static data members and inline function local statics.
              config_options+=("--enable-gnu-unique-object")
              config_options+=("--enable-gnu-indirect-function")
              config_options+=("--enable-linker-build-id")

              # Inspired from mingw-w64; apart from --with-sysroot.
              config_options+=("--with-native-system-header-dir=${APP_PREFIX}${name_suffix}/include")

              # Arch also uses --disable-dw2-exceptions
              # config_options+=("--disable-dw2-exceptions")

              if [ ${MINGW_VERSION_MAJOR} -ge 7 -a ${gcc_version_major} -ge 9 ]
              then
                # Requires at least GCC 9 & mingw 7.
                config_options+=("--enable-libstdcxx-filesystem-ts=yes")
              fi

              # Fails!
              # config_options+=("--enable-default-pie")

              # Disable look up installations paths in the registry.
              config_options+=("--disable-win32-registry")
              # Turn off symbol versioning in the shared library
              config_options+=("--disable-symvers")

              config_options+=("--disable-libitm")
              config_options+=("--with-tune=generic")

              config_options+=("--with-stabs")
              config_options+=("--with-gnu-as")
              config_options+=("--with-gnu-ld")

              # config_options+=("--disable-libssp")
              # msys2: --disable-libssp should suffice in GCC 8
              # export gcc_cv_libc_provides_ssp=yes
              # libssp: conflicts with builtin SSP

              # so libgomp DLL gets built despide static libdl
              # export lt_cv_deplibs_check_method='pass_all'

            else
              echo "Oops! Unsupported ${TARGET_PLATFORM}."
              exit 1
            fi
          fi

          echo ${config_options[@]}

          gcc --version
          cc --version
          ${CC} --version

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
            ${config_options[@]}

          if [ "${TARGET_PLATFORM}" == "linux" ]
          then
            run_verbose sed -i.bak \
              -e "s|^\(POSTSTAGE1_LDFLAGS = .*\)$|\1 -Wl,-rpath,${LD_LIBRARY_PATH}|" \
              "Makefile"
          fi

          cp "config.log" "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/config-log-$(ndate).txt"

        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gcc${name_suffix} make..."

        if [ -n "${name_suffix}" ]
        then

          run_verbose make -j ${JOBS} all-gcc
          run_verbose make install-strip-gcc

          show_native_libs "${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc"
          show_native_libs "${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-g++"

          show_native_libs "$(${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc --print-prog-name=cc1)"
          show_native_libs "$(${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc --print-prog-name=cc1plus)"
          show_native_libs "$(${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc --print-prog-name=collect2)"
          show_native_libs "$(${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc --print-prog-name=lto1)"
          show_native_libs "$(${APP_PREFIX}${name_suffix}/bin/${CROSS_COMPILE_PREFIX}-gcc --print-prog-name=lto-wrapper)"

        else

          # Build.
          run_verbose make -j ${JOBS}

          run_verbose make install-strip

          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            echo
            echo "Removing unnecessary files..."

            rm -rfv "${APP_PREFIX}/bin/gcc-ar"
            rm -rfv "${APP_PREFIX}/bin/gcc-nm"
            rm -rfv "${APP_PREFIX}/bin/gcc-ranlib"
          elif [ "${TARGET_PLATFORM}" == "win32" ]
          then
            # If the bootstrap was compiled with shared libs, copy
            # libwinpthread.dll here, since it'll be referenced by
            # several executables.
            # For just in case, currently the builds are static.
            if [ -f "${APP_PREFIX}${BOOTSTRAP_SUFFIX}/${CROSS_COMPILE_PREFIX}/bin/libwinpthread-1.dll" ]
            then
              run_verbose install -c -m 755 "${APP_PREFIX}${BOOTSTRAP_SUFFIX}/${CROSS_COMPILE_PREFIX}/bin/libwinpthread-1.dll" \
                "${APP_PREFIX}/bin"
            fi
          fi

          show_libs "${APP_PREFIX}/bin/gcc"
          show_libs "${APP_PREFIX}/bin/g++"

          if [ "${TARGET_PLATFORM}" != "win32" ]
          then
            show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1)"
            show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1plus)"
            show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=collect2)"
            show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto1)"
            show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto-wrapper)"
          fi

          if [ "${TARGET_PLATFORM}" == "linux" ]
          then
            show_libs "$(${APP_PREFIX}/bin/gcc --print-file-name=libstdc++.so)"
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            show_libs "$(${APP_PREFIX}/bin/gcc --print-file-name=libstdc++.dylib)"
          fi

          (
            xbb_activate_tex

            # Full build, with documentation.
            if [ "${WITH_PDF}" == "y" ]
            then
              run_verbose make pdf
              run_verbose make install-pdf
            fi

            if [ "${WITH_HTML}" == "y" ]
            then
              run_verbose make html
              run_verbose make install-html
            fi
          )
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-output-$(ndate).txt"
    )

    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc${name_suffix} already installed."
  fi

  if [ -n "${name_suffix}" ]
  then
    :
  else
    tests_add "test_gcc_final"
  fi
}

# Currently not used, work done by build_gcc_final().
function build_gcc_libs()
{
  local gcc_libs_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-libs-installed"
  if [ ! -f "${gcc_libs_stamp_file_path}" ]
  then
  (
    mkdir -p "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
    cd "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

    CPPFLAGS="${XBB_CPPFLAGS}"
    CFLAGS="${XBB_CFLAGS_NO_W}"
    CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

    LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

    export CPPFLAGS
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS

    (
      if [ "${IS_DEVELOP}" == "y" ]
      then
        env | sort
      fi

      echo
      echo "Running gcc-libs make..."

      run_verbose make -j ${JOBS} all-target-libgcc
      run_verbose make install-strip-target-libgcc

    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-libs-output-$(ndate).txt"
  )

    touch "${gcc_libs_stamp_file_path}"
  else
    echo "Component gcc-libs already installed."
  fi
}

function build_gcc_final()
{
  local gcc_final_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-final-installed"
  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then
    (
      mkdir -p "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      (
        if [ "${IS_DEVELOP}" == "y" ]
        then
          env | sort
        fi

        echo
        echo "Running gcc-final make..."

        run_verbose make -j ${JOBS}
        run_verbose make install-strip

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-final-output-$(ndate).txt"
    )

    touch "${gcc_final_stamp_file_path}"
  else
    echo "Component gcc-final already installed."
  fi

  tests_add "test_gcc_bootstrap"
}

function test_gcc_bootstrap()
{
  (
    # Use XBB libs in native-llvm
    xbb_activate_libs

    test_gcc "${BOOTSTRAP_SUFFIX}"
  )
}

function test_gcc_final()
{
  (
    test_gcc
  )
}

function test_gcc()
{
  local name_suffix=${1-''}

  echo
  echo "Testing the gcc${name_suffix} binaries..."

  (
    if [ -d "xpacks/.bin" ]
    then
      TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${APP_PREFIX}${name_suffix}/bin" ]
    then
      TEST_BIN_PATH="${APP_PREFIX}${name_suffix}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    run_verbose ls -l "${TEST_BIN_PATH}"

    if [ -n "${name_suffix}" ]
    then

      if true
      then
        # The DLLs are spread around.
        # .../lib/gcc/x86_64-w64-mingw32/libgcc_s_seh-1.dll
        # .../lib/gcc/x86_64-w64-mingw32/11.1.0/libstdc++-6.dll
        # .../x86_64-w64-mingw32/bin/libwinpthread-1.dll
        # No longer used, the bootstrap is also static.
        # export WINEPATH="${TEST_BIN_PATH}/lib/gcc/${CROSS_COMPILE_PREFIX};${TEST_BIN_PATH}/lib/gcc/${CROSS_COMPILE_PREFIX}/${GCC_VERSION};${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}/bin"
        CC="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-gcc"
        CXX="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-g++"
      else
        # Calibrate tests with the XBB binaries.
        export WINEPATH="${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/lib;${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/bin"
        CC="${XBB_FOLDER_PATH}/usr/bin/${CROSS_COMPILE_PREFIX}-gcc"
        CXX="${XBB_FOLDER_PATH}/usr/bin/${CROSS_COMPILE_PREFIX}-g++"
      fi

      AR="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-gcc-ar"
      NM="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-gcc-nm"
      RANLIB="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-gcc-ranlib"

      DLLTOOL="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-dlltool"
      GENDEF="${TEST_BIN_PATH}/gendef"
      WIDL="${TEST_BIN_PATH}/${CROSS_COMPILE_PREFIX}-widl"

    else

      CC="${TEST_BIN_PATH}/gcc"
      CXX="${TEST_BIN_PATH}/g++"

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        AR="ar"
        NM="nm"
        RANLIB="ranlib"
      else
        AR="${TEST_BIN_PATH}/gcc-ar"
        NM="${TEST_BIN_PATH}/gcc-nm"
        RANLIB="${TEST_BIN_PATH}/gcc-ranlib"

        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          WIDL="${TEST_BIN_PATH}/widl"
        fi
      fi

    fi

    show_libs "${CC}"
    show_libs "${CXX}"

    if [ "${TARGET_PLATFORM}" != "win32" ]
    then
      show_libs "$(${CC} --print-prog-name=cc1)"
      show_libs "$(${CC} --print-prog-name=cc1plus)"
      show_libs "$(${CC} --print-prog-name=collect2)"
      show_libs "$(${CC} --print-prog-name=lto1)"
      show_libs "$(${CC} --print-prog-name=lto-wrapper)"
    fi

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      show_libs "$(${CC} --print-file-name=libgcc_s.so)"
      show_libs "$(${CC} --print-file-name=libstdc++.so)"
    elif [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      local libgcc_path="$(${CC} --print-file-name=libgcc_s.1.dylib)"
      if [ "${libgcc_path}" != "libgcc_s.1.dylib" ]
      then
        show_libs "$(${CC} --print-file-name=libgcc_s.1.dylib)"
      fi
      show_libs "$(${CC} --print-file-name=libstdc++.dylib)"
    fi

    echo
    echo "Testing if the gcc${name_suffix} binaries start properly..."

    run_app "${CC}" --version
    run_app "${CXX}" --version

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # On Darwin they refer to existing Darwin tools
      # which do not support --version
      # TODO: On Windows: gcc-ar.exe: Cannot find binary 'ar'
      run_app "${AR}" --version
      run_app "${NM}" --version
      run_app "${RANLIB}" --version
    fi

    if [ -n "${name_suffix}" ]
    then
      :
    else
      run_app "${TEST_BIN_PATH}/gcov" --version
      run_app "${TEST_BIN_PATH}/gcov-dump" --version
      run_app "${TEST_BIN_PATH}/gcov-tool" --version
    fi

    echo
    echo "Showing the gcc${name_suffix} configurations..."

    run_app "${CC}" -v
    run_app "${CC}" -dumpversion
    run_app "${CC}" -dumpmachine
    run_app "${CC}" -print-search-dirs
    run_app "${CC}" -print-libgcc-file-name
    run_app "${CC}" -print-multi-directory
    run_app "${CC}" -print-multi-lib
    run_app "${CC}" -print-multi-os-directory

    echo
    echo "Testing if gcc${name_suffix} ${GCC_VERSION} compiles several programs..."

    local tests_folder_path="${WORK_FOLDER_PATH}/${TARGET_FOLDER_NAME}"
    mkdir -pv "${tests_folder_path}/tests"
    local tmp="$(mktemp "${tests_folder_path}/tests/test-gcc${name_suffix}-XXXXXXXXXX")"
    rm -rf "${tmp}"

    mkdir -p "${tmp}"
    cd "${tmp}"

    echo
    echo "pwd: $(pwd)"

    # -------------------------------------------------------------------------

    cp -v "${helper_folder_path}/tests/c-cpp"/* .

    VERBOSE_FLAG=""
    if [ "${IS_DEVELOP}" == "y" ]
    then
      VERBOSE_FLAG="-v"
    fi

    if [ "${TARGET_PLATFORM}" == "linux" ]
    then
      GC_SECTION="-Wl,--gc-sections"
    elif [ "${TARGET_PLATFORM}" == "darwin" ]
    then
      GC_SECTION="-Wl,-dead_strip"
    else
      GC_SECTION=""
    fi

    echo
    env | sort

    run_verbose uname
    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_verbose uname -o
    fi

    # -------------------------------------------------------------------------

    (
      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        # Instruct the linker to add a RPATH pointing to the folder with the
        # compiler shared libraries. Alternatelly -Wl,-rpath=xxx can be used
        # explicitly on each link command.
        # Ubuntu 14 has no realpath
        # export LD_RUN_PATH="$(dirname $(realpath $(${CC} --print-file-name=libgcc_s.so)))"
        export LD_RUN_PATH="$(dirname $(${CC} --print-file-name=libgcc_s.so))"
        echo
        echo "LD_RUN_PATH=${LD_RUN_PATH}"
      elif [ "${TARGET_PLATFORM}" == "win32" -a ! -n "${name_suffix}" ]
      then
        # For libwinpthread-1.dll, possibly other.
        if [ "$(uname -o)" == "Msys" ]
        then
          export PATH="${TEST_BIN_PATH}/lib;${PATH:-}"
          echo "PATH=${PATH}"
        elif [ "$(uname)" == "Linux" ]
        then
          export WINEPATH="${TEST_BIN_PATH}/lib;${WINEPATH:-}"
          echo "WINEPATH=${WINEPATH}"
        fi
      fi

      test_gcc_one "" "${name_suffix}"
    )

    # This is the recommended use case, and it is expected to work
    # properly on all platforms.
    test_gcc_one "static-lib-" "${name_suffix}"

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      test_gcc_one "static-" "${name_suffix}"
    elif [ "${TARGET_PLATFORM}" == "linux" ]
    then
      # On Linux static linking is highly discouraged
      echo "Skip --static"
      # test_gcc_one "static-" "${name_suffix}"
    fi

    # -------------------------------------------------------------------------

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      run_app "${CC}" -o add.o -c add.c -ffunction-sections -fdata-sections
    else
      run_app "${CC}" -o add.o -c add.c -fpic -ffunction-sections -fdata-sections
    fi

    rm -rf libadd-static.a
    run_app "${AR}" -r ${VERBOSE_FLAG} libadd-static.a add.o
    run_app "${RANLIB}" libadd-static.a

    run_app "${CC}" ${VERBOSE_FLAG} -o static-adder${DOT_EXE} adder.c -ladd-static -L . -ffunction-sections -fdata-sections ${GC_SECTION}
    test_expect "static-adder" "42" 40 2

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      # The `--out-implib` creates an import library, which can be
      # directly used with -l.
      run_app "${CC}" ${VERBOSE_FLAG} -o libadd-shared.dll -shared -Wl,--out-implib,libadd-shared.dll.a add.o -Wl,--subsystem,windows
      # -ladd-shared is in fact libadd-shared.dll.a
      # The library does not show as DLL, it is loaded dynamically.
      run_app "${CC}" ${VERBOSE_FLAG} -o shared-adder${DOT_EXE} adder.c -ladd-shared -L . -ffunction-sections -fdata-sections ${GC_SECTION}
      test_expect "shared-adder" "42" 40 2
    else
      run_app "${CC}" -o libadd-shared.${SHLIB_EXT} add.o -shared
      run_app "${CC}" ${VERBOSE_FLAG} -o shared-adder adder.c -ladd-shared -L . -ffunction-sections -fdata-sections ${GC_SECTION}
      (
        LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
        export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}
        test_expect "shared-adder" "42" 40 2
      )
    fi

    # -------------------------------------------------------------------------
  )

  echo
  echo "Testing the gcc${name_suffix} binaries completed successfuly."
}

function test_gcc_one()
{
  local prefix="$1" # "", "static-lib-", "static-"
  local suffix="$2" # "-bootstrap"

  if [ "${prefix}" == "static-lib-" ]
  then
      STATIC_LIBGCC="-static-libgcc"
      STATIC_LIBSTD="-static-libstdc++"
  elif [ "${prefix}" == "static-" ]
  then
      STATIC_LIBGCC="-static"
      STATIC_LIBSTD=""
  else
      STATIC_LIBGCC=""
      STATIC_LIBSTD=""
  fi

  # Test C compile and link in a single step.
  run_app "${CC}" -v -o ${prefix}simple-hello-c1${suffix}${DOT_EXE} simple-hello.c ${STATIC_LIBGCC}
  test_expect "${prefix}simple-hello-c1${suffix}" "Hello"

  # Test C compile and link in a single step with gc.
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}gc-simple-hello-c1${suffix}${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC}
  test_expect "${prefix}gc-simple-hello-c1${suffix}" "Hello"

  # Test C compile and link in separate steps.
  run_app "${CC}" -o simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}simple-hello-c2${suffix}${DOT_EXE} simple-hello-c.o ${GC_SECTION} ${STATIC_LIBGCC}
  test_expect "${prefix}simple-hello-c2${suffix}" "Hello"

  # Test LTO C compile and link in a single step.
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-c1${suffix}${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC}
  test_expect "${prefix}lto-simple-hello-c1${suffix}" "Hello"

  # Test LTO C compile and link in separate steps.
  run_app "${CC}" -o lto-simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections -flto
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-c2${suffix}${DOT_EXE} lto-simple-hello-c.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC}
  test_expect "${prefix}lto-simple-hello-c2${suffix}" "Hello"

  # ---------------------------------------------------------------------------

  # Test C++ compile and link in a single step.
  run_app "${CXX}" -v -o ${prefix}simple-hello-cpp1${suffix}${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}simple-hello-cpp1${suffix}" "Hello"

  # Test C++ compile and link in separate steps.
  run_app "${CXX}" -o simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-hello-cpp2${suffix}${DOT_EXE} simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}simple-hello-cpp2${suffix}" "Hello"

  # Test LTO C++ compile and link in a single step.
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-cpp1${suffix}${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}lto-simple-hello-cpp1${suffix}" "Hello"

  # Test LTO C++ compile and link in separate steps.
  run_app "${CXX}" -o lto-simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections -flto
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-cpp2${suffix}${DOT_EXE} lto-simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}lto-simple-hello-cpp2${suffix}" "Hello"

  # ---------------------------------------------------------------------------

  if [ "${TARGET_PLATFORM}" == "darwin" -a "${prefix}" == "" ]
  then
    # 'Symbol not found: __ZdlPvm' (_operator delete(void*, unsigned long))
    run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-exception${suffix}${DOT_EXE} simple-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs ${prefix}simple-exception${suffix}
    run_app ./${prefix}simple-exception${suffix} || echo "The test ${prefix}simple-exception${suffix} is known to fail; ignored."
  else
    run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-exception${suffix}${DOT_EXE} simple-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    test_expect "${prefix}simple-exception${suffix}" "MyException"
  fi

  # -O0 is an attempt to prevent any interferences with the optimiser.
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-str-exception${suffix}${DOT_EXE} simple-str-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}simple-str-exception${suffix}" "MyStringException"

  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-int-exception${suffix}${DOT_EXE} simple-int-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "${prefix}simple-int-exception${suffix}" "42"

  # ---------------------------------------------------------------------------
  # Test a very simple Objective-C (a printf).

  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}simple-objc${suffix}${DOT_EXE} simple-objc.m -O0 ${STATIC_LIBGCC}
  test_expect "${prefix}simple-objc${suffix}" "Hello World"

  # ---------------------------------------------------------------------------
  # Tests borrowed from the llvm-mingw project.

  run_app "${CC}" -o ${prefix}hello${suffix}${DOT_EXE} hello.c ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
  show_libs ${prefix}hello${suffix}
  run_app ./${prefix}hello${suffix}

  run_app "${CC}" -o ${prefix}setjmp${suffix}${DOT_EXE} setjmp-patched.c ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
  show_libs ${prefix}setjmp${suffix}
  run_app ./${prefix}setjmp${suffix}

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    run_app "${CC}" -o ${prefix}hello-tls${suffix}.exe hello-tls.c ${VERBOSE_FLAG} ${STATIC_LIBGCC}
    show_libs ${prefix}hello-tls${suffix}
    run_app ./${prefix}hello-tls${suffix}

    run_app "${CC}" -o ${prefix}crt-test${suffix}.exe crt-test.c ${VERBOSE_FLAG} ${STATIC_LIBGCC}
    show_libs ${prefix}crt-test${suffix}
    run_app ./${prefix}crt-test${suffix}

    if [ "${prefix}" != "static-" ]
    then
      run_app "${CC}" -o autoimport-lib.dll autoimport-lib.c -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${VERBOSE_FLAG} ${STATIC_LIBGCC}
      show_libs autoimport-lib.dll

      run_app "${CC}" -o ${prefix}autoimport-main${suffix}.exe autoimport-main.c -L. -lautoimport-lib ${VERBOSE_FLAG} ${STATIC_LIBGCC}
      show_libs ${prefix}autoimport-main${suffix}
      run_app ./${prefix}autoimport-main${suffix}
    fi

    # The IDL output isn't arch specific, but test each arch frontend
    run_app "${WIDL}" -o idltest.h idltest.idl -h
    run_app "${CC}" -o ${prefix}idltest${suffix}.exe idltest.c -I. -lole32 ${VERBOSE_FLAG} ${STATIC_LIBGCC}
    show_libs ${prefix}idltest${suffix}
    run_app ./${prefix}idltest${suffix}
  fi

  run_app ${CXX} -o ${prefix}hello-cpp${suffix}${DOT_EXE} hello-cpp.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}hello-cpp${suffix}
  run_app ./${prefix}hello-cpp${suffix}

  run_app ${CXX} -o ${prefix}hello-exception${suffix}${DOT_EXE} hello-exception.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}hello-exception${suffix}
  run_app ./${prefix}hello-exception${suffix}

  run_app ${CXX} -o ${prefix}exception-locale${suffix}${DOT_EXE} exception-locale.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}exception-locale${suffix}
  run_app ./${prefix}exception-locale${suffix}

  run_app ${CXX} -o ${prefix}exception-reduced${suffix}${DOT_EXE} exception-reduced.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}exception-reduced${suffix}
  run_app ./${prefix}exception-reduced${suffix}

  run_app ${CXX} -o ${prefix}global-terminate${suffix}${DOT_EXE} global-terminate.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}global-terminate${suffix}
  run_app ./${prefix}global-terminate${suffix}

  run_app ${CXX} -o ${prefix}longjmp-cleanup${suffix}${DOT_EXE} longjmp-cleanup.cpp ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}longjmp-cleanup${suffix}
  run_app ./${prefix}longjmp-cleanup${suffix}

  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    run_app ${CXX} -o tlstest-lib.dll tlstest-lib.cpp -shared -Wl,--out-implib,libtlstest-lib.dll.a ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs tlstest-lib.dll

    run_app ${CXX} -o ${prefix}tlstest-main${suffix}.exe tlstest-main.cpp ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs ${prefix}tlstest-main${suffix}

    (
      # For libstdc++-6.dll
      if [ "$(uname -o)" == "Msys" ]
      then
        export PATH="${TEST_BIN_PATH}/lib;${PATH:-}"
        echo "PATH=${PATH}"
      elif [ "$(uname)" == "Linux" ]
      then
        export WINEPATH="${TEST_BIN_PATH}/lib;${WINEPATH:-}"
        echo "WINEPATH=${WINEPATH}"
      fi

      if false # [ "${TARGET_ARCH}" == "ia32" ]
      then
        if [ "$(uname)" == "Linux" ]
        then
          # "lock.c: LOCKTABLEENTRY.crit" wait timed out in thread 0062, blocked by 0063, retrying (60 sec)
          echo "The test ${prefix}tlstest-main${suffix} is known to hang on wine; ignored."
        elif [ "$(uname -o)" == "Msys" -a "${prefix}" == "static-" ]
        then
          echo "The test ${prefix}tlstest-main${suffix} is known to hang on GitHub Actions; ignored."
        else
          run_app ./${prefix}tlstest-main${suffix} || echo "The test ${prefix}tlstest-main${suffix} is known to fail; ignored."
        fi
      else
        run_app ./${prefix}tlstest-main${suffix}
      fi
    )
  fi

  if [ "${prefix}" != "static-" ]
  then
    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      run_app ${CXX} -o throwcatch-lib.dll throwcatch-lib.cpp -shared -Wl,--out-implib,libthrowcatch-lib.dll.a ${VERBOSE_FLAG}
    else
      run_app ${CXX} -o libthrowcatch-lib.${SHLIB_EXT} throwcatch-lib.cpp -shared -fpic ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    fi

    run_app ${CXX} -o ${prefix}throwcatch-main${suffix}${DOT_EXE} throwcatch-main.cpp -L. -lthrowcatch-lib ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}

    (
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
      export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}

      show_libs ${prefix}throwcatch-main${suffix}
      if [ "${TARGET_PLATFORM}" == "win32" -a "${TARGET_ARCH}" == "ia32" ]
      then
        run_app ./${prefix}throwcatch-main${suffix} || echo "The test ${prefix}throwcatch-main${suffix} is known to fail; ignored."
      elif [ "${TARGET_PLATFORM}" == "darwin" -a "${prefix}" == "" ]
      then
        # dyld: Symbol not found: __ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE5c_strEv
        run_app ./${prefix}throwcatch-main${suffix} || echo "The test ${prefix}throwcatch-main${suffix} is known to fail; ignored."
      else
        run_app ./${prefix}throwcatch-main${suffix}
      fi
    )
  fi

  # Test if the linker is able to link weak symbols.
  if [ "${TARGET_PLATFORM}" == "win32" ]
  then
    # On Windows only the -flto linker is capable of understanding weak symbols.
    run_app "${CC}" -c -o ${prefix}hello-weak${suffix}.c.o hello-weak.c -flto
    run_app "${CC}" -c -o ${prefix}hello-f-weak${suffix}.c.o hello-f-weak.c -flto
    run_app "${CC}" -o ${prefix}hello-weak${suffix}${DOT_EXE} ${prefix}hello-weak${suffix}.c.o ${prefix}hello-f-weak${suffix}.c.o ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC} -flto
    test_expect ./${prefix}hello-weak${suffix} "Hello World!"
  else
    run_app "${CC}" -c -o ${prefix}hello-weak${suffix}.c.o hello-weak.c
    run_app "${CC}" -c -o ${prefix}hello-f-weak${suffix}.c.o hello-f-weak.c
    run_app "${CC}" -o ${prefix}hello-weak${suffix}${DOT_EXE} ${prefix}hello-weak${suffix}.c.o ${prefix}hello-f-weak${suffix}.c.o ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
    test_expect ./${prefix}hello-weak${suffix} "Hello World!"
  fi
}

# -----------------------------------------------------------------------------

# Called multile times, with and without python support.
# $1="" or $1="-py3"
function build_gdb()
{
  # https://www.gnu.org/software/gdb/
  # https://ftp.gnu.org/gnu/gdb/
  # https://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.xz

  # GDB Text User Interface
  # https://ftp.gnu.org/old-gnu/Manuals/gdb/html_chapter/gdb_19.html#SEC197

  # 2019-05-11, "8.3"
  # 2020-02-08, "9.1"
  # 2020-05-23, "9.2"
  # 2020-10-24, "10.1"
  # 2021-04-25, "10.2"

  local gdb_version="$1"

  local gdb_src_folder_name="gdb-${gdb_version}"

  local gdb_archive="${gdb_src_folder_name}.tar.xz"
  local gdb_url="https://ftp.gnu.org/gnu/gdb/${gdb_archive}"

  local gdb_folder_name="${gdb_src_folder_name}"

  local gdb_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-${gdb_folder_name}-installed"

  if [ ! -f "${gdb_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"
    mkdir -pv "${LOGS_FOLDER_PATH}/${gdb_folder_name}"

    # Download gdb
    if [ ! -d "${SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" ]
    then
      download_and_extract "${gdb_url}" "${gdb_archive}" \
        "${gdb_src_folder_name}"
    fi

    (
      mkdir -pv "${BUILD_FOLDER_PATH}/${gdb_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gdb_folder_name}"

      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        # Used to enable wildcard; inspired from arm-none-eabi-gcc.
        LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/lib/CRT_glob.o"

        # Hack to place the bcrypt library at the end of the list of libraries,
        # to avoid 'undefined reference to BCryptGenRandom'.
        # Using LIBS does not work, the order is important.
        export DEBUGINFOD_LIBS="-lbcrypt"
      elif [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH:-${LIBS_INSTALL_FOLDER_PATH}/lib}"
      elif [ "${TARGET_PLATFORM}" == "linux" ]
      then
        :
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS
      export LIBS

      if [ ! -f "config.status" ]
      then
        (
          if [ "${IS_DEVELOP}" == "y" ]
          then
            env | sort
          fi

          echo
          echo "Running gdb configure..."

          bash "${SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/gdb/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")
          config_options+=("--program-suffix=")

          config_options+=("--infodir=${APP_PREFIX_DOC}/info")
          config_options+=("--mandir=${APP_PREFIX_DOC}/man")
          config_options+=("--htmldir=${APP_PREFIX_DOC}/html")
          config_options+=("--pdfdir=${APP_PREFIX_DOC}/pdf")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--with-pkgversion=${GDB_BRANDING}")

          config_options+=("--with-expat")
          config_options+=("--with-lzma=yes")

          config_options+=("--with-python=no")

          config_options+=("--without-guile")
          config_options+=("--without-babeltrace")
          config_options+=("--without-libunwind-ia64")

          config_options+=("--disable-nls")
          config_options+=("--disable-sim")
          config_options+=("--disable-gas")
          config_options+=("--disable-binutils")
          config_options+=("--disable-ld")
          config_options+=("--disable-gprof")
          config_options+=("--disable-source-highlight")

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then
            config_options+=("--disable-tui")
          else
            config_options+=("--enable-tui")
          fi

          config_options+=("--disable-werror")
          config_options+=("--enable-build-warnings=no")

          # Note that all components are disabled, except GDB.
          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${LOGS_FOLDER_PATH}/${gdb_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gdb_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gdb make..."

        # Build.
        run_verbose make -j ${JOBS}

        # install-strip fails, not only because of readline has no install-strip
        # but even after patching it tries to strip a non elf file
        # strip:.../install/riscv-none-gcc/bin/_inst.672_: file format not recognized
        run_verbose make install-gdb

        (
          xbb_activate_tex

          if [ "${WITH_PDF}" == "y" ]
          then
            run_verbose make pdf
            run_verbose make install-pdf
          fi

          if [ "${WITH_HTML}" == "y" ]
          then
            run_verbose make html
            run_verbose make install-html
          fi
        )

        show_libs "${APP_PREFIX}/bin/gdb"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gdb_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" \
        "${gdb_folder_name}"

    )

    touch "${gdb_stamp_file_path}"
  else
    echo "Component gdb already installed."
  fi

  tests_add "test_gdb"
}

function test_gdb()
{
  (
    if [ -d "xpacks/.bin" ]
    then
      TEST_BIN_PATH="$(pwd)/xpacks/.bin"
    elif [ -d "${APP_PREFIX}/bin" ]
    then
      TEST_BIN_PATH="${APP_PREFIX}/bin"
    else
      echo "Wrong folder."
      exit 1
    fi

    show_libs "${TEST_BIN_PATH}/gdb"

    run_app "${TEST_BIN_PATH}/gdb" --version
    run_app "${TEST_BIN_PATH}/gdb" --help
    run_app "${TEST_BIN_PATH}/gdb" --config

    # This command is known to fail with 'Abort trap: 6' (SIGABRT)
    run_app "${TEST_BIN_PATH}/gdb" \
      --nh \
      --nx \
      -ex='show language' \
      -ex='set language auto' \
      -ex='quit'

  )
}

# -----------------------------------------------------------------------------
