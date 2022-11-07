# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------

function download_gcc()
{
  local gcc_version="$1"

  # Branch from the Darwin maintainer of GCC with Apple Silicon support,
  # located at https://github.com/iains/gcc-darwin-arm64 and
  # backported with his help to gcc-11 branch.

  # The repo used by the HomeBrew:
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc.rb
  # https://github.com/Homebrew/homebrew-core/blob/master/Formula/gcc@12.rb
  # https://github.com/fxcoudert/gcc/tags

  export GCC_SRC_FOLDER_NAME="gcc-${gcc_version}"

  local gcc_archive="${GCC_SRC_FOLDER_NAME}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"
  local gcc_patch_file_name="gcc-${gcc_version}.patch.diff"

  if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "12.2.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/1d184289/gcc/gcc-12.2.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin-arm.patch.diff"
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "12.1.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/d61235ed/gcc/gcc-12.1.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin-arm.patch.diff"
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "11.3.0" ]
  then
    # https://raw.githubusercontent.com/Homebrew/formula-patches/22dec3fc/gcc/gcc-11.3.0-arm.diff
    local gcc_patch_file_name="gcc-${gcc_version}-darwin-arm.patch.diff"
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "11.2.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.2.0-arm-20211201.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.2.0-arm-20211201"
    local gcc_archive="gcc-11.2.0-arm-20211201.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${XBB_TARGET_ARCH}" == "arm64" -a "${gcc_version}" == "11.1.0" ]
  then
    # https://github.com/fxcoudert/gcc/archive/refs/tags/gcc-11.1.0-arm-20210504.tar.gz
    export GCC_SRC_FOLDER_NAME="gcc-gcc-11.1.0-arm-20210504"
    local gcc_archive="gcc-11.1.0-arm-20210504.tar.gz"
    local gcc_url="https://github.com/fxcoudert/gcc/archive/refs/tags/${gcc_archive}"
    local gcc_patch_file_name=""
  fi

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}"

  local gcc_download_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_SRC_FOLDER_NAME}-downloaded"
  if [ ! -f "${gcc_download_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" \
      "${GCC_SRC_FOLDER_NAME}" "${gcc_patch_file_name}"

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
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

  # https://github.com/archlinux/svntogit-packages/blob/packages/gcc/trunk/PKGBUILD
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
  # 2022-04-21, "11.3.0"
  # 2022-05-06, "12.1.0"
  # 2022-08-19, "12.2.0"

  local gcc_version="$1"
  local name_suffix=${2-''}

  if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" -a "${XBB_TARGET_PLATFORM}" != "win32" ]
  then
    echo "Native supported only for Windows binaries."
    exit 1
  fi

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  export GCC_FOLDER_NAME="${GCC_SRC_FOLDER_NAME}${name_suffix}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}"

  local gcc_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
      then

        CPPFLAGS="${XBB_CPPFLAGS} -I${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}/include"
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

        if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then
          if [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
          then
            # From MSYS2 MINGW
            LDFLAGS+=" -Wl,--large-address-aware"
          fi
          # From MSYS2, but not supported by GCC 9
          # LDFLAGS+=" -Wl,--disable-dynamicbase"

          # Used to enable wildcard; inspired from arm-none-eabi-gcc.
          # LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${XBB_CROSS_COMPILE_PREFIX}/lib/CRT_glob.o"

          # Hack to prevent "too many sections", "File too big" etc in insn-emit.c
          CXXFLAGS=$(echo ${CXXFLAGS} | sed -e 's|-ffunction-sections -fdata-sections||')
          CXXFLAGS+=" -D__USE_MINGW_ACCESS"
        fi

        if [ "${XBB_TARGET_PLATFORM}" == "linux" -o "${XBB_TARGET_PLATFORM}" == "darwin" ]
        then
          xbb_activate_cxx_rpath
          LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH:-${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/lib}"

          export LDFLAGS_FOR_TARGET="${LDFLAGS}"
          export LDFLAGS_FOR_BUILD="${LDFLAGS}"
          export BOOT_LDFLAGS="${LDFLAGS}"
        fi
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gcc${name_suffix} configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" --help
          bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/gcc/configure" --help

          bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libgcc/configure" --help
          bash "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/libstdc++-v3/configure" --help

          config_options=()

          if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
          then

            # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc-base

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
            config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")

            config_options+=("--build=${XBB_BUILD}")
            # The bootstrap binaries will run on the build machine.
            config_options+=("--host=${XBB_BUILD}")
            config_options+=("--target=${XBB_TARGET}")

            config_options+=("--with-pkgversion=${XBB_GCC_BOOTSTRAP_BRANDING}")

            config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

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
            config_options+=("--enable-lto") # Arch
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

            config_options+=("--prefix=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}")
            config_options+=("--program-suffix=")

            config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
            config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
            config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
            config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

            config_options+=("--build=${XBB_BUILD}")
            config_options+=("--host=${XBB_HOST}")
            config_options+=("--target=${XBB_TARGET}")

            config_options+=("--with-pkgversion=${XBB_GCC_BRANDING}")

            config_options+=("--with-build-config=bootstrap-lto") # Arch
            # config_options+=("--with-gcc-major-version-only") # HB

            if [ "${XBB_TARGET_PLATFORM}" != "linux" ]
            then
              config_options+=("--with-libiconv-prefix=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}")
            fi

            config_options+=("--with-dwarf2")
            config_options+=("--with-libiconv")
            config_options+=("--with-isl")
            config_options+=("--with-diagnostics-color=auto")

            config_options+=("--with-gmp=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}${name_suffix}")

            # config_options+=("--without-system-zlib")
            config_options+=("--with-system-zlib") # HB, Arch
            config_options+=("--without-cuda-driver")

            config_options+=("--enable-languages=c,c++,objc,obj-c++,lto,fortran") # HB
            config_options+=("--enable-objc-gc=auto")

            # Intel specific.
            # config_options+=("--enable-cet=auto")
            config_options+=("--enable-checking=release") # HB, Arch

            config_options+=("--enable-lto") # Arch
            config_options+=("--enable-plugin") # Arch

            config_options+=("--enable-__cxa_atexit") # Arch
            config_options+=("--enable-cet=auto") # Arch

            config_options+=("--enable-threads=posix")

            # It fails on macOS master with:
            # libstdc++-v3/include/bits/cow_string.h:630:9: error: no matching function for call to 'std::basic_string<wchar_t>::_Alloc_hider::_Alloc_hider(std::basic_string<wchar_t>::_Rep*)'
            # config_options+=("--enable-fully-dynamic-string")
            config_options+=("--enable-cloog-backend=isl")

            config_options+=("--enable-default-pie") # Arch

            # The GNU Offloading and Multi Processing Runtime Library
            config_options+=("--enable-libgomp")

            # config_options+=("--disable-libssp") # Arch
            config_options+=("--enable-libssp")

            config_options+=("--enable-default-ssp") # Arch
            config_options+=("--enable-libatomic")
            config_options+=("--enable-graphite")
            config_options+=("--enable-libquadmath")
            config_options+=("--enable-libquadmath-support")

            config_options+=("--enable-libstdcxx")
            config_options+=("--enable-libstdcxx-backtrace") # Arch
            config_options+=("--enable-libstdcxx-time=yes")
            config_options+=("--enable-libstdcxx-visibility")
            config_options+=("--enable-libstdcxx-threads")

            config_options+=("--enable-shared") # Arch
            config_options+=("--enable-shared-libgcc")

            config_options+=("--enable-static")

            config_options+=("--with-default-libstdcxx-abi=new")

            config_options+=("--enable-pie-tools")

            # config_options+=("--enable-version-specific-runtime-libs")

            # TODO
            # config_options+=("--enable-nls")
            config_options+=("--disable-nls") # HB

            # config_options+=("--disable-multilib")
            config_options+=("--enable-multilib") # Arch


            config_options+=("--disable-libstdcxx-debug")
            config_options+=("--disable-libstdcxx-pch") # Arch

            config_options+=("--disable-install-libiberty")

            # It is not yet clear why, but Arch, RH use it.
            # config_options+=("--disable-libunwind-exceptions")

            config_options+=("--disable-werror") # Arch

            if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
            then

              # DO NOT DISABLE, otherwise 'ld: library not found for -lgcc_ext.10.5'.
              # config_options+=("--enable-shared")
              # config_options+=("--enable-shared-libgcc")

              # This distribution expects the SDK to be installed
              # with the Command Line Tools, which have a fixed location,
              # while Xcode may vary from version to version.
              config_options+=("--with-sysroot=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk") # HB

              # From HomeBrew, but not present on 11.x
              # config_options+=("--with-native-system-header-dir=/usr/include")

              if [ "${XBB_IS_DEVELOP}" == "y" ]
              then
                # To speed things up during development.
                config_options+=("--disable-bootstrap")
              else
                config_options+=("--enable-bootstrap")
              fi

            elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
            then

              # Shared libraries remain problematic when refered from generated
              # programs, and require setting the executable rpath to work.
              # config_options+=("--enable-shared")
              # config_options+=("--enable-shared-libgcc")

              if [ "${XBB_IS_DEVELOP}" == "y" ]
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

              if [ "${XBB_TARGET_ARCH}" == "x64" ]
              then
                config_options+=("--with-arch=x86-64")
                config_options+=("--with-tune=generic")
                # Support for Intel Memory Protection Extensions (MPX).
                config_options+=("--enable-libmpx")
              elif [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
              then
                config_options+=("--with-arch=i686")
                config_options+=("--with-arch-32=i686")
                config_options+=("--with-tune=generic")
                config_options+=("--enable-libmpx")
              elif [ "${XBB_TARGET_ARCH}" == "arm64" ]
              then
                config_options+=("--with-arch=armv8-a")
                config_options+=("--enable-fix-cortex-a53-835769")
                config_options+=("--enable-fix-cortex-a53-843419")
              elif [ "${XBB_TARGET_ARCH}" == "arm" ]
              then
                config_options+=("--with-arch=armv7-a")
                config_options+=("--with-float=hard")
                config_options+=("--with-fpu=vfpv3-d16")
              else
                echo "Oops! Unsupported ${XBB_TARGET_ARCH}."
                exit 1
              fi

              config_options+=("--with-pic")

              config_options+=("--with-stabs")
              config_options+=("--with-gnu-as")
              config_options+=("--with-gnu-ld")

              # Used by Arch
              # config_options+=("--disable-libunwind-exceptions")
              # config_options+=("--disable-libssp")
              config_options+=("--with-linker-hash-style=gnu") # Arch
              config_options+=("--enable-clocale=gnu") # Arch

              # Tells GCC to use the gnu_unique_object relocation for C++
              # template static data members and inline function local statics.
              config_options+=("--enable-gnu-unique-object") # Arch
              config_options+=("--enable-gnu-indirect-function") # Arch
              config_options+=("--enable-linker-build-id") # Arch

              # Not needed.
              # config_options+=("--with-sysroot=${XBB_BINARIES_INSTALL_FOLDER_PATH}")
              # config_options+=("--with-native-system-header-dir=/usr/include")

            elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
            then

              # With shared 32-bit, the simple-exception and other
              # tests with exceptions, fail.
              # config_options+=("--disable-shared")
              # config_options+=("--disable-shared-libgcc")

              if [ "${XBB_TARGET_ARCH}" == "x64" ]
              then
                config_options+=("--with-arch=x86-64")
              elif [ "${XBB_TARGET_ARCH}" == "x32" -o "${XBB_TARGET_ARCH}" == "ia32" ]
              then
                config_options+=("--with-arch=i686")

                # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
                # The defaults are sjlj for 32-bit and seh for 64-bit,
                # So better disable SJLJ explicitly.
                config_options+=("--disable-sjlj-exceptions")
              else
                echo "Oops! Unsupported ${XBB_TARGET_ARCH}."
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
              config_options+=("--with-native-system-header-dir=${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/include")

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
              echo "Oops! Unsupported ${XBB_TARGET_PLATFORM}."
              exit 1
            fi
          fi

          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${GCC_SRC_FOLDER_NAME}/configure" \
            ${config_options[@]}

          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            run_verbose sed -i.bak \
              -e "s|^\(POSTSTAGE1_LDFLAGS = .*\)$|\1 -Wl,-rpath,${LD_LIBRARY_PATH}|" \
              "Makefile"
          fi

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/config-log-$(ndate).txt"

        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gcc${name_suffix} make..."

        if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
        then

          run_verbose make -j ${XBB_JOBS} all-gcc
          run_verbose make install-strip-gcc

          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc"
          show_native_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-g++"

          show_native_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc --print-prog-name=cc1)"
          show_native_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc --print-prog-name=cc1plus)"
          show_native_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc --print-prog-name=collect2)"
          show_native_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc --print-prog-name=lto1)"
          show_native_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc --print-prog-name=lto-wrapper)"

        else

          # Build.
          run_verbose make -j ${XBB_JOBS}

          run_verbose make install-strip

          if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            echo
            echo "Removing unnecessary files..."

            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc-ar"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc-nm"
            rm -rfv "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc-ranlib"
          elif [ "${XBB_TARGET_PLATFORM}" == "win32" ]
          then
            # If the bootstrap was compiled with shared libs, copy
            # libwinpthread.dll here, since it'll be referenced by
            # several executables.
            # For just in case, currently the builds are static.
            if [ -f "${XBB_BINARIES_INSTALL_FOLDER_PATH}${XBB_BOOTSTRAP_SUFFIX}/${XBB_CROSS_COMPILE_PREFIX}/bin/libwinpthread-1.dll" ]
            then
              run_verbose install -c -m 755 "${XBB_BINARIES_INSTALL_FOLDER_PATH}${XBB_BOOTSTRAP_SUFFIX}/${XBB_CROSS_COMPILE_PREFIX}/bin/libwinpthread-1.dll" \
                "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin"
            fi
          fi

          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc"
          show_libs "${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/g++"

          if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
          then
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=cc1)"
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=cc1plus)"
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=collect2)"
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=lto1)"
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-prog-name=lto-wrapper)"
          fi

          if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
          then
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-file-name=libstdc++.so)"
          elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
          then
            show_libs "$(${XBB_BINARIES_INSTALL_FOLDER_PATH}/bin/gcc --print-file-name=libstdc++.dylib)"
          fi
        fi

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_stamp_file_path}"

  else
    echo "Component gcc${name_suffix} already installed."
  fi

  if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
  then
    :
  else
    tests_add "test_gcc_final" "${XBB_BINARIES_INSTALL_FOLDER_PATH}${name_suffix}/bin"
  fi
}

# Currently not used, work done by build_gcc_final().
function build_gcc_libs()
{
  local gcc_libs_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-libs-installed"
  if [ ! -f "${gcc_libs_stamp_file_path}" ]
  then
  (
    mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
    cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

    CPPFLAGS="${XBB_CPPFLAGS}"
    CFLAGS="${XBB_CFLAGS_NO_W}"
    CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

    LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

    export CPPFLAGS
    export CFLAGS
    export CXXFLAGS
    export LDFLAGS

    (
      if [ "${XBB_IS_DEVELOP}" == "y" ]
      then
        env | sort
      fi

      echo
      echo "Running gcc-libs make..."

      run_verbose make -j ${XBB_JOBS} all-target-libgcc
      run_verbose make install-strip-target-libgcc

    ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-libs-output-$(ndate).txt"
  )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_libs_stamp_file_path}"
  else
    echo "Component gcc-libs already installed."
  fi
}

function build_gcc_final()
{
  local gcc_final_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${GCC_FOLDER_NAME}-final-installed"
  if [ ! -f "${gcc_final_stamp_file_path}" ]
  then
    (
      mkdir -p "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"
      cd "${XBB_BUILD_FOLDER_PATH}/${GCC_FOLDER_NAME}"

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC} -Wl,-rpath,${XBB_FOLDER_PATH}/lib"

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      (
        if [ "${XBB_IS_DEVELOP}" == "y" ]
        then
          env | sort
        fi

        echo
        echo "Running gcc-final make..."

        run_verbose make -j ${XBB_JOBS}
        run_verbose make install-strip

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${GCC_FOLDER_NAME}/make-final-output-$(ndate).txt"
    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gcc_final_stamp_file_path}"
  else
    echo "Component gcc-final already installed."
  fi

  tests_add "test_gcc_bootstrap"
}

function test_gcc_bootstrap()
{
  local test_bin_path="$1"
  (
    # Use XBB libs in native-llvm
    xbb_activate_libs

    test_gcc "${test_bin_path}" "${XBB_BOOTSTRAP_SUFFIX}"
  )
}

function test_gcc_final()
{
  local test_bin_path="$1"
  (
    test_gcc "${test_bin_path}"
  )
}

function test_gcc()
{
  local test_bin_path="$1"
  local name_suffix=${2:-''}

  echo
  echo "Testing the gcc${name_suffix} binaries..."

  (
    run_verbose ls -l "${test_bin_path}"

    if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
    then

      if true
      then
        # The DLLs are spread around.
        # .../lib/gcc/x86_64-w64-mingw32/libgcc_s_seh-1.dll
        # .../lib/gcc/x86_64-w64-mingw32/11.1.0/libstdc++-6.dll
        # .../x86_64-w64-mingw32/bin/libwinpthread-1.dll
        # No longer used, the bootstrap is also static.
        # export WINEPATH="${test_bin_path}/lib/gcc/${XBB_CROSS_COMPILE_PREFIX};${test_bin_path}/lib/gcc/${XBB_CROSS_COMPILE_PREFIX}/${XBB_GCC_VERSION};${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}/bin"
        CC="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-gcc"
        CXX="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-g++"
      else
        # Calibrate tests with the XBB binaries.
        export WINEPATH="${XBB_FOLDER_PATH}/usr/${XBB_CROSS_COMPILE_PREFIX}/lib;${XBB_FOLDER_PATH}/usr/${XBB_CROSS_COMPILE_PREFIX}/bin"
        CC="${XBB_FOLDER_PATH}/usr/bin/${XBB_CROSS_COMPILE_PREFIX}-gcc"
        CXX="${XBB_FOLDER_PATH}/usr/bin/${XBB_CROSS_COMPILE_PREFIX}-g++"
      fi

      AR="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-gcc-ar"
      NM="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-gcc-nm"
      RANLIB="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-gcc-ranlib"

      DLLTOOL="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-dlltool"
      GENDEF="${test_bin_path}/gendef"
      WIDL="${test_bin_path}/${XBB_CROSS_COMPILE_PREFIX}-widl"

    else

      CC="${test_bin_path}/gcc"
      CXX="${test_bin_path}/g++"

      if [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
      then
        AR="ar"
        NM="nm"
        RANLIB="ranlib"
      else
        AR="${test_bin_path}/gcc-ar"
        NM="${test_bin_path}/gcc-nm"
        RANLIB="${test_bin_path}/gcc-ranlib"

        if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
        then
          WIDL="${test_bin_path}/widl"
        fi
      fi

    fi

    show_libs "${CC}"
    show_libs "${CXX}"

    if [ "${XBB_TARGET_PLATFORM}" != "win32" ]
    then
      show_libs "$(${CC} --print-prog-name=cc1)"
      show_libs "$(${CC} --print-prog-name=cc1plus)"
      show_libs "$(${CC} --print-prog-name=collect2)"
      show_libs "$(${CC} --print-prog-name=lto1)"
      show_libs "$(${CC} --print-prog-name=lto-wrapper)"
    fi

    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      show_libs "$(${CC} --print-file-name=libgcc_s.so)"
      show_libs "$(${CC} --print-file-name=libstdc++.so)"
    elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
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

    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      # On Darwin they refer to existing Darwin tools
      # which do not support --version
      # TODO: On Windows: gcc-ar.exe: Cannot find binary 'ar'
      run_app "${AR}" --version
      run_app "${NM}" --version
      run_app "${RANLIB}" --version
    fi

    if [ "${name_suffix}" == "${XBB_BOOTSTRAP_SUFFIX}" ]
    then
      :
    else
      run_app "${test_bin_path}/gcov" --version
      run_app "${test_bin_path}/gcov-dump" --version
      run_app "${test_bin_path}/gcov-tool" --version
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
    echo "Testing if gcc${name_suffix} ${XBB_GCC_VERSION} compiles several programs..."

    rm -rf "${XBB_TESTS_FOLDER_PATH}/gcc${name_suffix}"
    mkdir -pv "${XBB_TESTS_FOLDER_PATH}/gcc${name_suffix}"; cd "${XBB_TESTS_FOLDER_PATH}/gcc${name_suffix}"

    echo
    echo "pwd: $(pwd)"

    # -------------------------------------------------------------------------

    cp -rv "${helper_folder_path}/tests/c-cpp"/* .

    VERBOSE_FLAG=""
    if [ "${XBB_IS_DEVELOP}" == "y" ]
    then
      VERBOSE_FLAG="-v"
    fi

    if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      GC_SECTION="-Wl,--gc-sections"
    elif [ "${XBB_TARGET_PLATFORM}" == "darwin" ]
    then
      GC_SECTION="-Wl,-dead_strip"
    else
      GC_SECTION=""
    fi

    run_verbose uname
    if [ "${XBB_TARGET_PLATFORM}" != "darwin" ]
    then
      run_verbose uname -o
    fi

    # -------------------------------------------------------------------------

    (
      if [ "${XBB_TARGET_PLATFORM}" == "linux" ]
      then
        # Instruct the linker to add a RPATH pointing to the folder with the
        # compiler shared libraries. Alternatelly -Wl,-rpath=xxx can be used
        # explicitly on each link command.
        # Ubuntu 14 has no realpath
        # export LD_RUN_PATH="$(dirname $(realpath $(${CC} --print-file-name=libgcc_s.so)))"
        export LD_RUN_PATH="$(dirname $(${CC} --print-file-name=libgcc_s.so))"
        echo
        echo "LD_RUN_PATH=${LD_RUN_PATH}"
      elif [ "${XBB_TARGET_PLATFORM}" == "win32" -a -z "${name_suffix}" ]
      then
        # For libwinpthread-1.dll, possibly other.
        if [ "$(uname -o)" == "Msys" ]
        then
          export PATH="${test_bin_path}/lib;${PATH:-}"
          echo "PATH=${PATH}"
        elif [ "$(uname)" == "Linux" ]
        then
          export WINEPATH="${test_bin_path}/lib;${WINEPATH:-}"
          echo "WINEPATH=${WINEPATH}"
        fi
      fi

      test_gcc_one "" "${name_suffix}"
    )

    # This is the recommended use case, and it is expected to work
    # properly on all platforms.
    test_gcc_one "static-lib-" "${name_suffix}"

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      test_gcc_one "static-" "${name_suffix}"
    elif [ "${XBB_TARGET_PLATFORM}" == "linux" ]
    then
      # On Linux static linking is highly discouraged
      echo "Skip --static"
      # test_gcc_one "static-" "${name_suffix}"
    fi

    # -------------------------------------------------------------------------

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      run_app "${CC}" -o add.o -c add.c -ffunction-sections -fdata-sections
    else
      run_app "${CC}" -o add.o -c add.c -fpic -ffunction-sections -fdata-sections
    fi

    rm -rf libadd-static.a
    run_app "${AR}" -r ${VERBOSE_FLAG} libadd-static.a add.o
    run_app "${RANLIB}" libadd-static.a

    run_app "${CC}" ${VERBOSE_FLAG} -o static-adder${XBB_DOT_EXE} adder.c -ladd-static -L . -ffunction-sections -fdata-sections ${GC_SECTION}
    test_expect "42" "static-adder" 40 2

    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      # The `--out-implib` creates an import library, which can be
      # directly used with -l.
      run_app "${CC}" ${VERBOSE_FLAG} -o libadd-shared.dll -shared -Wl,--out-implib,libadd-shared.dll.a add.o -Wl,--subsystem,windows
      # -ladd-shared is in fact libadd-shared.dll.a
      # The library does not show as DLL, it is loaded dynamically.
      run_app "${CC}" ${VERBOSE_FLAG} -o shared-adder${XBB_DOT_EXE} adder.c -ladd-shared -L . -ffunction-sections -fdata-sections ${GC_SECTION}
      test_expect "42" "shared-adder" 40 2
    else
      run_app "${CC}" -o libadd-shared.${XBB_SHLIB_EXT} add.o -shared
      run_app "${CC}" ${VERBOSE_FLAG} -o shared-adder adder.c -ladd-shared -L . -ffunction-sections -fdata-sections ${GC_SECTION}
      (
        LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
        export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}
        test_expect "42" "shared-adder" 40 2
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
  run_app "${CC}" -v -o ${prefix}simple-hello-c1${suffix}${XBB_DOT_EXE} simple-hello.c ${STATIC_LIBGCC}
  test_expect "Hello" "${prefix}simple-hello-c1${suffix}"

  # Test C compile and link in a single step with gc.
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}gc-simple-hello-c1${suffix}${XBB_DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC}
  test_expect "Hello" "${prefix}gc-simple-hello-c1${suffix}"

  # Test C compile and link in separate steps.
  run_app "${CC}" -o simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}simple-hello-c2${suffix}${XBB_DOT_EXE} simple-hello-c.o ${GC_SECTION} ${STATIC_LIBGCC}
  test_expect "Hello" "${prefix}simple-hello-c2${suffix}"

  # Test LTO C compile and link in a single step.
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-c1${suffix}${XBB_DOT_EXE} simple-hello.c -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC}
  test_expect "Hello" "${prefix}lto-simple-hello-c1${suffix}"

  # Test LTO C compile and link in separate steps.
  run_app "${CC}" -o lto-simple-hello-c.o -c simple-hello.c -ffunction-sections -fdata-sections -flto
  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-c2${suffix}${XBB_DOT_EXE} lto-simple-hello-c.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC}
  test_expect "Hello" "${prefix}lto-simple-hello-c2${suffix}"

  # ---------------------------------------------------------------------------

  # Test C++ compile and link in a single step.
  run_app "${CXX}" -v -o ${prefix}simple-hello-cpp1${suffix}${XBB_DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "Hello" "${prefix}simple-hello-cpp1${suffix}"

  # Test C++ compile and link in separate steps.
  run_app "${CXX}" -o simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-hello-cpp2${suffix}${XBB_DOT_EXE} simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "Hello" "${prefix}simple-hello-cpp2${suffix}"

  # Test LTO C++ compile and link in a single step.
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-cpp1${suffix}${XBB_DOT_EXE} simple-hello.cpp -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "Hello" "${prefix}lto-simple-hello-cpp1${suffix}"

  # Test LTO C++ compile and link in separate steps.
  run_app "${CXX}" -o lto-simple-hello-cpp.o -c simple-hello.cpp -ffunction-sections -fdata-sections -flto
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}lto-simple-hello-cpp2${suffix}${XBB_DOT_EXE} lto-simple-hello-cpp.o -ffunction-sections -fdata-sections ${GC_SECTION} -flto ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "Hello" "${prefix}lto-simple-hello-cpp2${suffix}"

  # ---------------------------------------------------------------------------

  if [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${prefix}" == "" ]
  then
    # 'Symbol not found: __ZdlPvm' (_operator delete(void*, unsigned long))
    run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-exception${suffix}${XBB_DOT_EXE} simple-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs ${prefix}simple-exception${suffix}
    run_app ./${prefix}simple-exception${suffix} || echo "The test ${prefix}simple-exception${suffix} is known to fail; ignored."
  else
    run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-exception${suffix}${XBB_DOT_EXE} simple-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    test_expect "MyException" "${prefix}simple-exception${suffix}"
  fi

  # -O0 is an attempt to prevent any interferences with the optimiser.
  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-str-exception${suffix}${XBB_DOT_EXE} simple-str-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "MyStringException" "${prefix}simple-str-exception${suffix}"

  run_app "${CXX}" ${VERBOSE_FLAG} -o ${prefix}simple-int-exception${suffix}${XBB_DOT_EXE} simple-int-exception.cpp -ffunction-sections -fdata-sections ${GC_SECTION} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  test_expect "42" "${prefix}simple-int-exception${suffix}"

  # ---------------------------------------------------------------------------
  # Test a very simple Objective-C (a printf).

  run_app "${CC}" ${VERBOSE_FLAG} -o ${prefix}simple-objc${suffix}${XBB_DOT_EXE} simple-objc.m -O0 ${STATIC_LIBGCC}
  test_expect "Hello World" "${prefix}simple-objc${suffix}"

  # ---------------------------------------------------------------------------
  # Tests borrowed from the llvm-mingw project.

  run_app "${CC}" -o ${prefix}hello${suffix}${XBB_DOT_EXE} hello.c ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
  show_libs ${prefix}hello${suffix}
  run_app ./${prefix}hello${suffix}

  run_app "${CC}" -o ${prefix}setjmp${suffix}${XBB_DOT_EXE} setjmp-patched.c ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
  show_libs ${prefix}setjmp${suffix}
  run_app ./${prefix}setjmp${suffix}

  if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
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

  run_app ${CXX} -o ${prefix}hello-cpp${suffix}${XBB_DOT_EXE} hello-cpp.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}hello-cpp${suffix}
  run_app ./${prefix}hello-cpp${suffix}

  run_app ${CXX} -o ${prefix}hello-exception${suffix}${XBB_DOT_EXE} hello-exception.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}hello-exception${suffix}
  run_app ./${prefix}hello-exception${suffix}

  run_app ${CXX} -o ${prefix}exception-locale${suffix}${XBB_DOT_EXE} exception-locale.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}exception-locale${suffix}
  run_app ./${prefix}exception-locale${suffix}

  run_app ${CXX} -o ${prefix}exception-reduced${suffix}${XBB_DOT_EXE} exception-reduced.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}exception-reduced${suffix}
  run_app ./${prefix}exception-reduced${suffix}

  run_app ${CXX} -o ${prefix}global-terminate${suffix}${XBB_DOT_EXE} global-terminate.cpp -std=c++17 ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}global-terminate${suffix}
  run_app ./${prefix}global-terminate${suffix}

  run_app ${CXX} -o ${prefix}longjmp-cleanup${suffix}${XBB_DOT_EXE} longjmp-cleanup.cpp ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
  show_libs ${prefix}longjmp-cleanup${suffix}
  run_app ./${prefix}longjmp-cleanup${suffix}

  if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then
    run_app ${CXX} -o tlstest-lib.dll tlstest-lib.cpp -shared -Wl,--out-implib,libtlstest-lib.dll.a ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs tlstest-lib.dll

    run_app ${CXX} -o ${prefix}tlstest-main${suffix}.exe tlstest-main.cpp ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    show_libs ${prefix}tlstest-main${suffix}

    (
      # For libstdc++-6.dll
      if [ "$(uname -o)" == "Msys" ]
      then
        export PATH="${test_bin_path}/lib;${PATH:-}"
        echo "PATH=${PATH}"
      elif [ "$(uname)" == "Linux" ]
      then
        export WINEPATH="${test_bin_path}/lib;${WINEPATH:-}"
        echo "WINEPATH=${WINEPATH}"
      fi

      if false # [ "${XBB_TARGET_ARCH}" == "ia32" ]
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
    if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
    then
      run_app ${CXX} -o throwcatch-lib.dll throwcatch-lib.cpp -shared -Wl,--out-implib,libthrowcatch-lib.dll.a ${VERBOSE_FLAG}
    else
      run_app ${CXX} -o libthrowcatch-lib.${XBB_SHLIB_EXT} throwcatch-lib.cpp -shared -fpic ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}
    fi

    run_app ${CXX} -o ${prefix}throwcatch-main${suffix}${XBB_DOT_EXE} throwcatch-main.cpp -L. -lthrowcatch-lib ${VERBOSE_FLAG} ${STATIC_LIBGCC} ${STATIC_LIBSTD}

    (
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
      export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}

      show_libs ${prefix}throwcatch-main${suffix}
      if [ "${XBB_TARGET_PLATFORM}" == "win32" -a "${XBB_TARGET_ARCH}" == "ia32" ]
      then
        run_app ./${prefix}throwcatch-main${suffix} || echo "The test ${prefix}throwcatch-main${suffix} is known to fail; ignored."
      elif [ "${XBB_TARGET_PLATFORM}" == "darwin" -a "${prefix}" == "" ]
      then
        # dyld: Symbol not found: __ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE5c_strEv
        run_app ./${prefix}throwcatch-main${suffix} || echo "The test ${prefix}throwcatch-main${suffix} is known to fail; ignored."
      else
        run_app ./${prefix}throwcatch-main${suffix}
      fi
    )
  fi

  # Test if the linker is able to link weak symbols.
  if [ "${XBB_TARGET_PLATFORM}" == "win32" ]
  then
    # On Windows only the -flto linker is capable of understanding weak symbols.
    run_app "${CC}" -c -o ${prefix}hello-weak${suffix}.c.o hello-weak.c -flto
    run_app "${CC}" -c -o ${prefix}hello-f-weak${suffix}.c.o hello-f-weak.c -flto
    run_app "${CC}" -o ${prefix}hello-weak${suffix}${XBB_DOT_EXE} ${prefix}hello-weak${suffix}.c.o ${prefix}hello-f-weak${suffix}.c.o ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC} -flto
    test_expect "Hello World!" ./${prefix}hello-weak${suffix}
  else
    run_app "${CC}" -c -o ${prefix}hello-weak${suffix}.c.o hello-weak.c
    run_app "${CC}" -c -o ${prefix}hello-f-weak${suffix}.c.o hello-f-weak.c
    run_app "${CC}" -o ${prefix}hello-weak${suffix}${XBB_DOT_EXE} ${prefix}hello-weak${suffix}.c.o ${prefix}hello-f-weak${suffix}.c.o ${VERBOSE_FLAG} -lm ${STATIC_LIBGCC}
    test_expect "Hello World!" ./${prefix}hello-weak${suffix}
  fi
}

# -----------------------------------------------------------------------------
