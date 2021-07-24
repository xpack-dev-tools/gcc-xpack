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

function build_gcc() 
{
  # https://gcc.gnu.org
  # https://ftp.gnu.org/gnu/gcc/
  # https://gcc.gnu.org/wiki/InstallingGCC
  # https://gcc.gnu.org/install

  # https://github.com/archlinux/svntogit-community/blob/packages/gcc10/trunk/PKGBUILD
  # https://github.com/archlinux/svntogit-community/blob/packages/mingw-w64-gcc/trunk/PKGBUILD

  # https://archlinuxarm.org/packages/aarch64/gcc/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gcc-git
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@8.rb

  # Mingw on Arch
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc-base
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-headers
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-crt
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

  local gcc_version="$1"
  local name_suffix=${2-''}

  if [ -n "${name_suffix}" -a "${TARGET_PLATFORM}" != "win32" ]
  then
    echo "Native supported only for Windows binaries."
    exit 1
  fi

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  local gcc_src_folder_name="gcc-${gcc_version}"
  export GCC_FOLDER_NAME="${gcc_src_folder_name}${name_suffix}"

  local gcc_archive="${gcc_src_folder_name}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"

  local gcc_patch_file_name="gcc-${gcc_version}.patch"

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" \
      "${gcc_src_folder_name}" "${gcc_patch_file_name}"

    mkdir -pv "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"

    if false
    then
      (
        cd "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}"

        local stamp="stamp-prerequisites-downloaded"
        if [ ! -f "${stamp}" ]
        then
          run_verbose bash "contrib/download_prerequisites"

          touch "${stamp}"
        fi

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/prerequisites-output.txt"
    fi

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      if [ -n "${name_suffix}" ]
      then

        # Use XBB libs in native-llvm
        xbb_activate_dev
        xbb_activate_libs

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

        LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      else

        xbb_activate
        # To access the newly compiled libraries.
        # On Arm it still needs --with-gmp
        xbb_activate_installed_dev

        CPPFLAGS="${XBB_CPPFLAGS}"
        CFLAGS="${XBB_CFLAGS_NO_W}"
        CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
        LDFLAGS="${XBB_LDFLAGS_APP}"

        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          if [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
          then
            # From MSYS2 MINGW
            LDFLAGS+=" -Wl,--large-address-aware"
          fi
          # From MSYS2
          LDFLAGS+=" -Wl,--disable-dynamicbase"
        elif [ "${TARGET_PLATFORM}" == "linux" ]
        then
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
        elif [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          :
        else
          echo "Oops! Unsupported ${TARGET_PLATFORM}."
          exit 1
        fi

      fi

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          env | sort

          echo
          echo "Running gcc${name_suffix} configure..."

          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/gcc/configure" --help
          
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/libgcc/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/libstdc++-v3/configure" --help

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

            # Use the internal XBB libs.
            config_options+=("--with-gmp=${XBB_FOLDER_PATH}")
            config_options+=("--with-mpfr=${XBB_FOLDER_PATH}")
            config_options+=("--with-mpc=${XBB_FOLDER_PATH}")
            config_options+=("--with-isl=${XBB_FOLDER_PATH}")

            # config_options+=("--with-default-libstdcxx-abi=gcc4-compatible")
            config_options+=("--with-default-libstdcxx-abi=new")

            # config_options+=("--with-dwarf2")

            config_options+=("--disable-multilib")
            config_options+=("--disable-werror")
            config_options+=("--disable-shared")
            # config_options+=("--disable-shared-libgcc")

            config_options+=("--disable-nls")
            config_options+=("--disable-libgomp")

            config_options+=("--disable-sjlj-exceptions")
            config_options+=("--disable-libunwind-exceptions")
            config_options+=("--disable-win32-registry")
            config_options+=("--disable-libstdcxx-debug")
            config_options+=("--disable-libstdcxx-pch")

            config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")
            # config_options+=("--enable-objc-gc=auto")
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
            config_options+=("--enable-libstdcxx-time=yes")
            config_options+=("--enable-libstdcxx")
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

            # These libraries are already available via the environment
            # variables, but in some cases, like Arm builds, it is
            # better to provide them explicitly.
            config_options+=("--with-gmp=${LIBS_INSTALL_FOLDER_PATH}")
            config_options+=("--with-mpfr=${LIBS_INSTALL_FOLDER_PATH}")
            config_options+=("--with-mpc=${LIBS_INSTALL_FOLDER_PATH}")
            config_options+=("--with-isl=${LIBS_INSTALL_FOLDER_PATH}")
            if [ "${TARGET_PLATFORM}" != "linux" ]
            then
              config_options+=("--with-libiconv-prefix=${LIBS_INSTALL_FOLDER_PATH}")
            fi

            config_options+=("--with-dwarf2")
            config_options+=("--with-stabs")
            config_options+=("--with-libiconv")
            config_options+=("--with-isl")
            config_options+=("--with-gnu-as")
            config_options+=("--with-gnu-ld")
            config_options+=("--with-diagnostics-color=auto")

            config_options+=("--without-system-zlib")
            config_options+=("--without-cuda-driver")

            # Intel specific.
            # config_options+=("--enable-cet=auto")
            config_options+=("--enable-checking=release")
            config_options+=("--enable-linker-build-id")

            config_options+=("--enable-lto")
            config_options+=("--enable-plugin")

            config_options+=("--enable-static")

            config_options+=("--enable-__cxa_atexit")

            config_options+=("--enable-libstdcxx")
            config_options+=("--enable-install-libiberty")

            # Tells GCC to use the gnu_unique_object relocation for C++ 
            # template static data members and inline function local statics.
            config_options+=("--enable-gnu-unique-object")
            config_options+=("--enable-gnu-indirect-function")

            config_options+=("--enable-fully-dynamic-string")
            config_options+=("--enable-libstdcxx-time=yes")
            config_options+=("--enable-cloog-backend=isl")
            #  the GNU Offloading and Multi Processing Runtime Library
            config_options+=("--enable-libgomp")
            config_options+=("--enable-libssp")
            config_options+=("--enable-libatomic")
            config_options+=("--enable-graphite")
            config_options+=("--enable-libquadmath")
            config_options+=("--enable-libquadmath-support")

            config_options+=("--enable-libstdcxx-visibility")
            config_options+=("--enable-libstdcxx-threads")

  #          config_options+=("--enable-version-specific-runtime-libs")

            config_options+=("--enable-threads=posix")

            # TODO
            # config_options+=("--enable-nls")
            config_options+=("--disable-nls")

            config_options+=("--disable-multilib")
            config_options+=("--disable-libstdcxx-debug")
            config_options+=("--disable-libstdcxx-pch")

            # It is not yet clear why, but Arch, RH use it.
            config_options+=("--disable-libunwind-exceptions")

            config_options+=("--disable-werror")

            if true # [ "${IS_DEVELOP}" == "y" ]
            then
              # Presumably the available compiler is good enough.
              # Plus that it fails with:
              # - 'Undefined _libiconv' on Darwin
              # - recompile with -fPIC on Linux
              config_options+=("--disable-bootstrap")
            fi

            if [ "${TARGET_PLATFORM}" == "darwin" ]
            then

              # DO NOT DISABLE, otherwise 'ld: library not found for -lgcc_ext.10.5'.
              config_options+=("--enable-shared")
              config_options+=("--enable-shared-libgcc")

              config_options+=("--with-default-libstdcxx-abi=new")

              # TODO: use /Library/Developer/CommandLineTools
              local print_path="$(xcode-select -print-path)"
              if [ -d "${print_path}/SDKs/MacOSX.sdk" ]
              then
                # Without Xcode, use the SDK that comes with the CLT.
                MACOS_SDK_PATH="${print_path}/SDKs/MacOSX.sdk"
              elif [ -d "${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk" ]
              then
                # With Xcode, chose the SDK from the macOS platform.
                MACOS_SDK_PATH="${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
              elif [ -d "${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk" ]
              then
                # With Xcode, chose the SDK from the macOS platform.
                MACOS_SDK_PATH="${print_path}/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
              else
                echo "Cannot find SDK in ${print_path}."
                exit 1
              fi

              # Fail on macOS
              # --with-linker-hash-style=gnu 
              # --enable-libmpx 
              # --enable-clocale=gnu
              echo "${MACOS_SDK_PATH}"

              # Copy the SDK in the distribution, to have a standalone package.
              local sdk_name=$(basename ${MACOS_SDK_PATH})
              run_verbose rm -rf "${APP_PREFIX}/${sdk_name}/"
              run_verbose cp -R "${MACOS_SDK_PATH}" "${APP_PREFIX}/${sdk_name}"
              # Remove the manuals and save about 225 MB.
              run_verbose rm -rf "${APP_PREFIX}/${sdk_name}/usr/share/man/"

              config_options+=("--with-sysroot=${APP_PREFIX}/${sdk_name}")

              # From HomeBrew, but not present on 11.x
              # config_options+=("--with-native-system-header-dir=/usr/include")

              # config_options+=("--enable-languages=c,c++,lto")            
              config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")            
              config_options+=("--enable-objc-gc=auto")

              config_options+=("--enable-default-pie")
              # config_options+=("--enable-default-ssp")

              # On Darwin, libgfortran.5.dylib has a reference to /usr/lib/libz.1.dylib.

            elif [ "${TARGET_PLATFORM}" == "linux" ]
            then

              # Shared libraries remain problematic when refered from generated programs,
              # since they usually do not point to the custom toolchain location.
              config_options+=("--disable-shared")
              config_options+=("--disable-shared-libgcc")

              config_options+=("--with-default-libstdcxx-abi=new")

              # The Linux build also uses:
              # --with-linker-hash-style=gnu
              # --enable-libmpx (fails on arm)
              # --enable-clocale=gnu 
              # --enable-install-libiberty 

              # Ubuntu also used:
              # --enable-libstdcxx-debug 
              # --enable-libstdcxx-time=yes (links librt)
              # --with-default-libstdcxx-abi=new (default)

              # Support for Intel Memory Protection Extensions (MPX).
              # Fails on Mingw-w64. Not for Arm.
              # config_options+=("--enable-libmpx")
          
              if [ "${TARGET_ARCH}" == "x64" ]
              then
                config_options+=("--with-arch=x86-64")
                config_options+=("--with-tune=generic")
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

              # config_options+=("--enable-languages=c,c++,lto")
              config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")
              config_options+=("--enable-objc-gc=auto")

              # Used by Arch
              # config_options+=("--disable-libunwind-exceptions")
              # config_options+=("--disable-libssp")
              config_options+=("--with-linker-hash-style=gnu")
              config_options+=("--enable-clocale=gnu")

              config_options+=("--enable-default-pie")
              config_options+=("--enable-default-ssp")

              # Not needed.
              # config_options+=("--with-sysroot=${APP_PREFIX}")
              # config_options+=("--with-native-system-header-dir=/usr/include")

            elif [ "${TARGET_PLATFORM}" == "win32" ]
            then

              config_options+=("--disable-shared")
              config_options+=("--disable-shared-libgcc")

              config_options+=("--enable-languages=c,c++,objc,obj-c++,lto")
              config_options+=("--enable-objc-gc=auto")

              config_options+=("--enable-mingw-wildcard")

              # Inspired from mingw-w64; no --with-sysroot
              config_options+=("--with-native-system-header-dir=${APP_PREFIX}${name_suffix}/include")

              # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
              # The defaults are sjlj for 32-bit and seh for 64-bit, thus
              # better do not set anything explicitly, since disabling sjlj
              # fails on both 64/32-bit:
              # error: ‘__LIBGCC_EH_FRAME_SECTION_NAME__’ undeclared here
              # config_options+=("--disable-sjlj-exceptions")
              config_options+=("--disable-sjlj-exceptions")

              # Arch also uses --disable-dw2-exceptions
              # config_options+=("--disable-dw2-exceptions")

              if [ "${TARGET_ARCH}" == "x64" ]
              then
                config_options+=("--with-arch=x86-64")
              elif [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
              then
                config_options+=("--with-arch=i686")

                # Fails with
                # libgcc/config/i386/cygming-crtend.c:51:34: error: ‘__LIBGCC_EH_FRAME_SECTION_NAME__’ undeclared here
                # config_options+=("--disable-sjlj-exceptions")
              else
                echo "Oops! Unsupported ${TARGET_ARCH}."
                exit 1
              fi

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

              # msys2
              # config_options+=("--with-default-libstdcxx-abi=gcc4-compatible")
              config_options+=("--with-default-libstdcxx-abi=new")
              config_options+=("--disable-libitm")
              config_options+=("--with-tune=generic")

              # config_options+=("--disable-libssp")
              # msys2: --disable-libssp should suffice in GCC 8
              # export gcc_cv_libc_provides_ssp=yes
              # libssp: conflicts with builtin SSP

              # so libgomp DLL gets built despide static libdl
              export lt_cv_deplibs_check_method='pass_all'

            else
              echo "Oops! Unsupported ${TARGET_PLATFORM}."
              exit 1
            fi
          fi

          echo ${config_options[@]}

          gcc --version
          cc --version

          run_verbose bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/configure" \
            ${config_options[@]}
              
          cp "config.log" "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/config-log.txt"

        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/configure-output.txt"
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
          if [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            # From HomeBrew
            export BOOT_LDFLAGS="-Wl,-headerpad_max_install_names"
          elif [ "${TARGET_PLATFORM}" == "win32" ]
          then
            if false # [ ${gcc_version_major} -eq 10 ]
            then
              if [ "${TARGET_ARCH}" == "ia32" -o  "${TARGET_ARCH}" == "x64" ]
              then
                # Otherwise it'll include the cpuid.h found in the toolchain,
                # which most probably has a different version, and, it older,
                # this breaks with undefined macros.
                mkdir -pv "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}/gcc"
                cp -v "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/gcc/config/i386/cpuid.h" \
                  "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}/gcc"
              fi
            fi
          fi

          run_verbose make -j ${JOBS}

          # Hack for Linux!
          # Build again libstd++ with -fPIC, otherwise the toolchain will
          # fail building C++ shared libraries (the `throwcatch-main` test).
          if [ "${TARGET_PLATFORM}" == "linux" ]
          then
            (
              cd "${TARGET}/libstdc++-v3"

              # Manually add -DPIC -fPIC.
              run_verbose sed -i.bak \
                -e 's|^CPPFLAGS = $|CPPFLAGS = -DPIC|' \
                -e 's|^CFLAGS =\(.*\)$|CFLAGS =\1 -fPIC|' \
                -e 's|^CXXFLAGS =\(.*\)$|CXXFLAGS =\1 -fPIC|' \
                "Makefile"

              echo
              echo "Running gcc libstdc++ make again..."

              run_verbose make clean
              run_verbose make -j ${JOBS}
            )
          fi

          run_verbose make install-strip

          if [ "${TARGET_PLATFORM}" == "linux" ]
          then
            echo
            echo "Removing shared libraries..."
            run_verbose find "${APP_PREFIX}/lib"* \
              \( \
                -name 'libasan.so*' -o \
                -name 'libatomic.so*' -o \
                -name 'libgfortran.so*' -o \
                -name 'libgomp.so*' -o \
                -name 'libitm.so*' -o \
                -name 'lib*san*.so*' -o \
                -name 'libmpx.so*' -o \
                -name 'libmpxwrappers.so*' -o \
                -name 'libquadmath.so*' -o \
                -name 'libssp.so*' -o \
                -name 'libstdc++.so*' \
              \) \
              -print \
              -exec rm -fv {} \;
          elif [ "${TARGET_PLATFORM}" == "darwin" ]
          then
            echo
            echo "Removing shared libraries..."
            run_verbose find "${APP_PREFIX}/lib" -name '*.dylib' ! -name 'libgcc_*' \
              -exec rm -fv {} \;

            rm -rf "${APP_PREFIX}/bin/gcc-ar"
            rm -rf "${APP_PREFIX}/bin/gcc-nm"
            rm -rf "${APP_PREFIX}/bin/gcc-ranlib"
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

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-output.txt"
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

function build_gcc_libs()
{
  local gcc_libs_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-libs-installed"
  if [ ! -f "${gcc_libs_stamp_file_path}" ]
  then
  (
    mkdir -p "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
    cd "${BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

    # Use XBB libs in native-llvm
    xbb_activate_dev
    xbb_activate_libs

    CPPFLAGS="${XBB_CPPFLAGS}"
    CFLAGS="${XBB_CFLAGS_NO_W}"
    CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

    LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

    if [ "${IS_DEVELOP}" == "y" ]
    then
      LDFLAGS+=" -v"
    fi

    export CPPFLAGS
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS

    (
      env | sort

      echo
      echo "Running gcc-libs make..."

      run_verbose make -j ${JOBS} all-target-libgcc
      run_verbose make install-strip-target-libgcc

    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-libs-output.txt"
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

      # Use XBB libs in native-llvm
      xbb_activate_dev
      xbb_activate_libs

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      (
        env | sort

        echo
        echo "Running gcc-final make..."

        run_verbose make -j ${JOBS}
        run_verbose make install-strip

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-final-output.txt"
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
    TEST_PREFIX="${APP_PREFIX}${name_suffix}"

    if [ -n "${name_suffix}" ]
    then

      if true
      then
        export WINEPATH="${TEST_PREFIX}/${CROSS_COMPILE_PREFIX}/lib" 
        CC="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-gcc"
        CXX="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-g++"
      else
        # Calibrate tests with the XBB binaries.
        export WINEPATH="${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/lib;${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/bin" 
        CC="${XBB_FOLDER_PATH}/usr/bin/${CROSS_COMPILE_PREFIX}-gcc"
        CXX="${XBB_FOLDER_PATH}/usr/bin/${CROSS_COMPILE_PREFIX}-g++"
      fi

      AR="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-gcc-ar"
      NM="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-gcc-nm"
      RANLIB="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-gcc-ranlib"

      DLLTOOL="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-dlltool"
      GENDEF="${TEST_PREFIX}/bin/gendef"
      WIDL="${TEST_PREFIX}/bin/${CROSS_COMPILE_PREFIX}-widl"

    else

      CC="${APP_PREFIX}/bin/gcc"
      CXX="${APP_PREFIX}/bin/g++"

      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        AR="ar"
        NM="nm"
        RANLIB="ranlib"
      else
        AR="${APP_PREFIX}/bin/gcc-ar"
        NM="${APP_PREFIX}/bin/gcc-nm"
        RANLIB="${APP_PREFIX}/bin/gcc-ranlib"

        if [ "${TARGET_PLATFORM}" == "win32" ]
        then
          WIDL="${APP_PREFIX}/bin/widl"
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

    echo
    echo "Testing if gcc binaries start properly..."

    run_app "${CC}" --version
    run_app "${CXX}" --version

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      # On Darwin they refer to existing Darwin tools
      # which do not support --version
      run_app "${AR}" --version
      run_app "${NM}" --version
      run_app "${RANLIB}" --version
    fi

    if [ -n "${name_suffix}" ]
    then
      :
    else
      run_app "${APP_PREFIX}/bin/gcov" --version
      run_app "${APP_PREFIX}/bin/gcov-dump" --version
      run_app "${APP_PREFIX}/bin/gcov-tool" --version
    fi

    echo
    echo "Showing configurations..."

    run_app "${CC}" -v
    run_app "${CC}" -dumpversion
    run_app "${CC}" -dumpmachine
    run_app "${CC}" -print-search-dirs
    run_app "${CC}" -print-libgcc-file-name
    run_app "${CC}" -print-multi-directory
    run_app "${CC}" -print-multi-lib
    run_app "${CC}" -print-multi-os-directory

    echo
    echo "Testing if gcc compiles simple Hello programs..."

    local tests_folder_path="${WORK_FOLDER_PATH}/${TARGET_FOLDER_NAME}"
    mkdir -pv "${tests_folder_path}/tests"
    local tmp="$(mktemp "${tests_folder_path}/tests/test-gcc-XXXXXXXXXX")"
    rm -rf "${tmp}"

    mkdir -p "${tmp}"
    cd "${tmp}"

    echo
    echo "pwd: $(pwd)"

    local VERBOSE_FLAG=""
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

    # -------------------------------------------------------------------------

    cp -v "${helper_folder_path}/tests/c-cpp"/* .

    # Test C compile and link in a single step.
    run_app "${CC}" ${VERBOSE_FLAG} -o simple-hello-c1${DOT_EXE} simple-hello.c
    test_expect "simple-hello-c1" "Hello"

    # Test C compile and link in a single step with gc.
    run_app "${CC}" ${VERBOSE_FLAG} -o gc-simple-hello-c1${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION}
    test_expect "gc-simple-hello-c1" "Hello"

    run_app "${CC}" ${VERBOSE_FLAG} -o static-lib-simple-hello-c1${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc 
    test_expect "static-lib-simple-hello-c1" "Hello"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CC}" ${VERBOSE_FLAG} -o static-simple-hello-c1${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -static
      test_expect "static-simple-hello-c1" "Hello"
    fi

    # Test C compile and link in separate steps.
    run_app "${CC}" -o simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections
    run_app "${CC}" ${VERBOSE_FLAG} -o simple-hello-c2${DOT_EXE} simple-hello-c.o ${GC_SECTION}
    test_expect "simple-hello-c2" "Hello"

    # Test LTO C compile and link in a single step.
    run_app "${CC}" ${VERBOSE_FLAG} -o lto-simple-hello-c1${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -flto 
    test_expect "lto-simple-hello-c1" "Hello"

    # Test LTO C compile and link in separate steps.
    run_app "${CC}" -o lto-simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections -flto
    run_app "${CC}" ${VERBOSE_FLAG} -o lto-simple-hello-c2${DOT_EXE} lto-simple-hello-c.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto
    test_expect "lto-simple-hello-c2" "Hello"

    run_app "${CC}" ${VERBOSE_FLAG} -o static-lib-lto-simple-hello-c1${DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc -flto
    test_expect "static-lib-lto-simple-hello-c1" "Hello"

    # -------------------------------------------------------------------------

    # Test C++ compile and link in a single step.
    run_app "${CXX}" ${VERBOSE_FLAG} -o simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION}
    test_expect "simple-hello-cpp1" "Hello"

    # Note: the macOS linker ignores -static-libstdc++
    run_app "${CXX}" ${VERBOSE_FLAG} -o static-lib-simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc  -static-libstdc++
    test_expect "static-lib-simple-hello-cpp1" "Hello"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CXX}" ${VERBOSE_FLAG} -o static-simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -static
      test_expect "static-simple-hello-cpp1" "Hello"
    fi

    # Test C++ compile and link in separate steps.
    run_app "${CXX}" -o simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections
    run_app "${CXX}" ${VERBOSE_FLAG} -o simple-hello-cpp2${DOT_EXE} simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION}
    test_expect "simple-hello-cpp2" "Hello"

    # Test LTO C++ compile and link in a single step.
    run_app "${CXX}" ${VERBOSE_FLAG} -o lto-simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -flto
    test_expect "lto-simple-hello-cpp1" "Hello"

    run_app "${CXX}" ${VERBOSE_FLAG} -o static-lib-lto-simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc  -static-libstdc++ -flto
    test_expect "static-lib-lto-simple-hello-cpp1" "Hello"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CXX}" ${VERBOSE_FLAG} -o static-lto-simple-hello-cpp1${DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -static -flto
      test_expect "static-lto-simple-hello-cpp1" "Hello"
    fi

    # Test LTO C++ compile and link in separate steps.
    run_app "${CXX}" -o lto-simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections -flto
    run_app "${CXX}" ${VERBOSE_FLAG} -o lto-simple-hello-cpp2${DOT_EXE} lto-simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto
    test_expect "lto-simple-hello-cpp2" "Hello"

    # -------------------------------------------------------------------------

    # -O0 is an attempt to prevent any interferences with the optimiser.
    run_app "${CXX}" ${VERBOSE_FLAG} -o simple-exception${DOT_EXE} simple-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION}
    # TODO: on Darwin: 'Symbol not found: __ZdlPvm'
    test_expect "simple-exception" "MyException"

    run_app "${CXX}" ${VERBOSE_FLAG} -o static-lib-simple-exception${DOT_EXE} simple-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc  -static-libstdc++
    test_expect "static-lib-simple-exception" "MyException"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CXX}" ${VERBOSE_FLAG} -o static-simple-exception${DOT_EXE} simple-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION} -static
      test_expect "static-simple-exception" "MyException"
    fi

    # -O0 is an attempt to prevent any interferences with the optimiser.
    run_app "${CXX}" ${VERBOSE_FLAG} -o simple-str-exception${DOT_EXE} simple-str-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION} 
    test_expect "simple-str-exception" "MyStringException"

    run_app "${CXX}" ${VERBOSE_FLAG} -o static-lib-simple-str-exception${DOT_EXE} simple-str-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION} -static-libgcc  -static-libstdc++
    test_expect "static-lib-simple-str-exception" "MyStringException"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CXX}" ${VERBOSE_FLAG} -o static-simple-str-exception${DOT_EXE} simple-str-exception.cpp -O0 -ffunction-sections -fdata-sections ${GC_SECTION} -static
      test_expect "static-simple-str-exception" "MyStringException"
    fi

    # -------------------------------------------------------------------------
    # Test a very simple Objective-C (a printf).

    run_app "${CC}" ${VERBOSE_FLAG} -o simple-objc simple-objc.m -O0
    test_expect "simple-objc" "Hello World"

    run_app "${CC}" ${VERBOSE_FLAG} -o static-lib-simple-objc simple-objc.m -O0 -static-libgcc 
    test_expect "static-lib-simple-objc" "Hello World"

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      run_app "${CC}" ${VERBOSE_FLAG} -o static-simple-objc simple-objc.m -O0 -static-libgcc
      test_expect "static-simple-objc" "Hello World"
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
    # Tests borrowed from the llvm-mingw project.

    run_app "${CC}" -o hello${DOT_EXE} hello.c ${VERBOSE_FLAG} -lm
    show_libs hello
    run_app ./hello

    run_app "${CC}" -o setjmp-patched${DOT_EXE} setjmp-patched.c ${VERBOSE_FLAG} -lm
    show_libs setjmp-patched
    run_app ./setjmp-patched

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      run_app "${CC}" -o hello-tls.exe hello-tls.c ${VERBOSE_FLAG} 
      show_libs hello-tls
      run_app ./hello-tls

      run_app "${CC}" -o crt-test.exe crt-test.c ${VERBOSE_FLAG} 
      show_libs crt-test 
      run_app ./crt-test 

      run_app "${CC}" -o autoimport-lib.dll autoimport-lib.c -shared  -Wl,--out-implib,libautoimport-lib.dll.a ${VERBOSE_FLAG} 
      show_libs autoimport-lib.dll

      run_app "${CC}" -o autoimport-main.exe autoimport-main.c -L. -lautoimport-lib ${VERBOSE_FLAG}
      show_libs autoimport-main
      run_app ./autoimport-main

      # The IDL output isn't arch specific, but test each arch frontend 
      run_app "${WIDL}" -o idltest.h idltest.idl -h  
      run_app "${CC}" -o idltest.exe idltest.c -I. -lole32 ${VERBOSE_FLAG} 
      show_libs idltest
      run_app ./idltest 
    fi

    for test in hello-cpp hello-exception exception-locale exception-reduced global-terminate
    do
      run_app ${CXX} -o $test${DOT_EXE} $test.cpp -std=c++17 ${VERBOSE_FLAG}
      show_libs $test
      run_app ./$test
    done

    run_app ${CXX} -o longjmp-cleanup${DOT_EXE} longjmp-cleanup.cpp ${VERBOSE_FLAG}
    show_libs longjmp-cleanup
    if [ "${TARGET_PLATFORM}" == "win32" -a "${TARGET_ARCH}" == "x64" -a ${GCC_VERSION_MAJOR} -ge 10 ]
    then
      echo "Skip running longjmp-cleanup"
    else
      run_app ./longjmp-cleanup
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      run_app ${CXX} -o hello-exception-static.exe hello-exception.cpp ${VERBOSE_FLAG} -static

      show_libs hello-exception-static
      run_app ./hello-exception-static

      run_app ${CXX} -o tlstest-lib.dll tlstest-lib.cpp -shared -Wl,--out-implib,libtlstest-lib.dll.a ${VERBOSE_FLAG}
      show_libs tlstest-lib.dll

      run_app ${CXX} -o tlstest-main.exe tlstest-main.cpp ${VERBOSE_FLAG}
      show_libs tlstest-main
      if [ -n "${name_suffix}" -a "${TARGET_ARCH}" == "ia32" -a ${GCC_VERSION_MAJOR} -le 10 ]
      then
        echo "Skip running tlstest-main"
      else
        run_app ./tlstest-main 
      fi
    fi

    if [ "${TARGET_PLATFORM}" == "win32" ]
    then
      run_app ${CXX} -o throwcatch-lib.dll throwcatch-lib.cpp -shared -Wl,--out-implib,libthrowcatch-lib.dll.a ${VERBOSE_FLAG}
    else
      run_app ${CXX} -o libthrowcatch-lib.${SHLIB_EXT} throwcatch-lib.cpp -shared -fpic ${VERBOSE_FLAG}
    fi

    run_app ${CXX} -o throwcatch-main${DOT_EXE} throwcatch-main.cpp -L. -lthrowcatch-lib ${VERBOSE_FLAG}

    (
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
      export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}

      show_libs throwcatch-main
      if [ -n "${name_suffix}" -a "${TARGET_ARCH}" == "ia32" ]
      then
        echo "Skip running throwcatch-main"
      else
        run_app ./throwcatch-main
      fi
    )
  )

  echo
  echo "Testing the gcc${name_suffix} binaries completed successfuly."
}

# -----------------------------------------------------------------------------

function strip_libs()
{
  if [ "${WITH_STRIP}" == "y" ]
  then
    (
      xbb_activate

      echo
      echo "Stripping libraries..."

      cd "${APP_PREFIX}"

      if [ "${TARGET_PLATFORM}" == "linux" ]
      then
        run_verbose which strip

        local libs=$(find "${APP_PREFIX}" -type f \( -name \*.a -o -name \*.o -o -name \*.so \))
        for lib in ${libs}
        do
          echo "strip -S ${lib}"
          strip -S "${lib}"
        done
      fi
    )
  fi
}

# -----------------------------------------------------------------------------
