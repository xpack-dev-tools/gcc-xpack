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

# binutils should not be used on Darwin, the build is ok, but
# there are functional issues, due to the different ld/as/etc.

function build_binutils()
{
  # https://www.gnu.org/software/binutils/
  # https://ftp.gnu.org/gnu/binutils/

  # https://archlinuxarm.org/packages/aarch64/binutils/files/PKGBUILD
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=gdb-git

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD


  # 2017-07-24, "2.29"
  # 2018-01-28, "2.30"
  # 2018-07-18, "2.31.1"
  # 2019-02-02, "2.32"
  # 2019-10-12, "2.33.1"
  # 2020-02-01, "2.34"
  # 2020-07-24, "2.35"
  # 2020-09-19, "2.35.1"
  # 2021-01-24, "2.36"
  # 2021-01-30, "2.35.2"
  # 2021-02-06, "2.36.1"

  local binutils_version="$1"

  local binutils_src_folder_name="binutils-${binutils_version}"
  local binutils_folder_name="${binutils_src_folder_name}"

  local binutils_archive="${binutils_src_folder_name}.tar.xz"
  local binutils_url="https://ftp.gnu.org/gnu/binutils/${binutils_archive}"

  local binutils_patch_file_name="binutils-${binutils_version}.patch"

  local binutils_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-binutils-${binutils_version}-installed"
  if [ ! -f "${binutils_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${binutils_url}" "${binutils_archive}" \
      "${binutils_src_folder_name}" "${binutils_patch_file_name}"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${binutils_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${binutils_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${binutils_folder_name}"

      xbb_activate
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

        # Used to enable wildcard; inspired from arm-none-eabi-gcc.
        LDFLAGS+=" -Wl,${XBB_FOLDER_PATH}/usr/${CROSS_COMPILE_PREFIX}/lib/CRT_glob.o"
      elif [ "${TARGET_PLATFORM}" == "linux" ]
      then
        LDFLAGS+=" -Wl,-rpath,${LD_LIBRARY_PATH}"
      fi

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running binutils configure..."
      
          bash "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" --help

          bash "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/binutils/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/bfd/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/gas/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/ld/configure" --help

          # ? --without-python --without-curses, --with-expat
          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")

          config_options+=("--infodir=${APP_PREFIX_DOC}/info")
          config_options+=("--mandir=${APP_PREFIX_DOC}/man")
          config_options+=("--htmldir=${APP_PREFIX_DOC}/html")
          config_options+=("--pdfdir=${APP_PREFIX_DOC}/pdf")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--program-suffix=")
          config_options+=("--with-pkgversion=${BINUTILS_BRANDING}")

          # config_options+=("--with-lib-path=/usr/lib:/usr/local/lib")
          config_options+=("--with-sysroot=${APP_PREFIX}")

          config_options+=("--without-system-zlib")
          config_options+=("--with-pic")

          if [ "${TARGET_PLATFORM}" == "win32" ]
          then

            config_options+=("--enable-ld")

            if [ "${TARGET_ARCH}" == "x64" ]
            then
              # From MSYS2 MINGW
              config_options+=("--enable-64-bit-bfd")
            fi

            config_options+=("--enable-shared")
            config_options+=("--enable-shared-libgcc")

          elif [ "${TARGET_PLATFORM}" == "linux" ]
          then

            config_options+=("--enable-ld")

            config_options+=("--disable-shared")
            config_options+=("--disable-shared-libgcc")

          else
            echo "Oops! Unsupported ${TARGET_PLATFORM}."
            exit 1
          fi

          config_options+=("--enable-static")

          config_options+=("--enable-gold")
          config_options+=("--enable-lto")
          config_options+=("--enable-libssp")
          config_options+=("--enable-relro")
          config_options+=("--enable-threads")
          config_options+=("--enable-interwork")
          config_options+=("--enable-plugins")
          config_options+=("--enable-build-warnings=no")
          config_options+=("--enable-deterministic-archives")
          
          # TODO
          # config_options+=("--enable-nls")
          config_options+=("--disable-nls")

          config_options+=("--disable-werror")
          config_options+=("--disable-sim")
          config_options+=("--disable-gdb")

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}/configure" \
            ${config_options[@]}
            
          cp "config.log" "${LOGS_FOLDER_PATH}/${binutils_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${binutils_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running binutils make..."
      
        # Build.
        make -j ${JOBS} 

        if [ "${WITH_TESTS}" == "y" ]
        then
          : # make check
        fi
      
        # Avoid strip here, it may interfere with patchelf.
        # make install-strip
        make install

        if [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          : # rm -rv "${APP_PREFIX}/bin/strip"
        fi

        (
          xbb_activate_tex

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

        show_libs "${APP_PREFIX}/bin/ar"
        show_libs "${APP_PREFIX}/bin/as"
        show_libs "${APP_PREFIX}/bin/ld"
        show_libs "${APP_PREFIX}/bin/strip"
        show_libs "${APP_PREFIX}/bin/nm"
        show_libs "${APP_PREFIX}/bin/objcopy"
        show_libs "${APP_PREFIX}/bin/objdump"
        show_libs "${APP_PREFIX}/bin/ranlib"
        show_libs "${APP_PREFIX}/bin/size"
        show_libs "${APP_PREFIX}/bin/strings"

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${binutils_folder_name}/make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${binutils_src_folder_name}" \
        "${binutils_folder_name}"

    )

    touch "${binutils_stamp_file_path}"
  else
    echo "Component binutils already installed."
  fi

  tests_add "test_binutils"
}

function test_binutils()
{
  (
    show_libs "${APP_PREFIX}/bin/ar"
    show_libs "${APP_PREFIX}/bin/as"
    show_libs "${APP_PREFIX}/bin/ld"
    show_libs "${APP_PREFIX}/bin/strip"
    show_libs "${APP_PREFIX}/bin/nm"
    show_libs "${APP_PREFIX}/bin/objcopy"
    show_libs "${APP_PREFIX}/bin/objdump"
    show_libs "${APP_PREFIX}/bin/ranlib"
    show_libs "${APP_PREFIX}/bin/size"
    show_libs "${APP_PREFIX}/bin/strings"

    echo
    echo "Testing if binutils starts properly..."

    run_app "${APP_PREFIX}/bin/ar" --version
    run_app "${APP_PREFIX}/bin/as" --version
    run_app "${APP_PREFIX}/bin/ld" --version
    run_app "${APP_PREFIX}/bin/strip" --version
    run_app "${APP_PREFIX}/bin/nm" --version
    run_app "${APP_PREFIX}/bin/objcopy" --version
    run_app "${APP_PREFIX}/bin/objdump" --version
    run_app "${APP_PREFIX}/bin/ranlib" --version
    run_app "${APP_PREFIX}/bin/size" --version
    run_app "${APP_PREFIX}/bin/strings" --version
  )

  echo
  echo "Local binutils tests completed successfuly."
}

# -----------------------------------------------------------------------------

function build_gcc() 
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
  # 2021-04-27, "11.1.0"
  # 2021-05-14, "8.5.0" *

  local gcc_version="$1"

  local gcc_version_major=$(echo ${gcc_version} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')

  local gcc_src_folder_name="gcc-${gcc_version}"
  local gcc_folder_name="${gcc_src_folder_name}"

  local gcc_archive="${gcc_src_folder_name}.tar.xz"
  local gcc_url="https://ftp.gnu.org/gnu/gcc/gcc-${gcc_version}/${gcc_archive}"

  local gcc_patch_file_name="gcc-${gcc_version}.patch"

  local gcc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-${gcc_folder_name}-installed"
  if [ ! -f "${gcc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${gcc_url}" "${gcc_archive}" \
      "${gcc_src_folder_name}" "${gcc_patch_file_name}"

    mkdir -pv "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}"

    (
      cd "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}"

      local stamp="stamp-prerequisites-downloaded"
      if [ ! -f "${stamp}" ]
      then
        bash "contrib/download_prerequisites"

        touch "${stamp}"
      fi

    ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${gcc_src_folder_name}/prerequisites-output.txt"

    (
      mkdir -p "${BUILD_FOLDER_PATH}/${gcc_folder_name}"
      cd "${BUILD_FOLDER_PATH}/${gcc_folder_name}"


      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_APP}"

      # Used when compiling the libraries.
      CPPFLAGS_FOR_TARGET="${XBB_CPPFLAGS}"
      
      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        if [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
        then
          # From MSYS2 MINGW
          LDFLAGS+=" -Wl,--large-address-aware"
        fi
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

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CPPFLAGS_FOR_TARGET
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      env | sort

      if [ ! -f "config.status" ]
      then
        (
          echo
          echo "Running gcc configure..."

          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/gcc/configure" --help
          
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/libgcc/configure" --help
          bash "${SOURCES_FOLDER_PATH}/${gcc_src_folder_name}/libstdc++-v3/configure" --help

          config_options=()

          config_options+=("--prefix=${APP_PREFIX}")

          config_options+=("--infodir=${APP_PREFIX_DOC}/info")
          config_options+=("--mandir=${APP_PREFIX_DOC}/man")
          config_options+=("--htmldir=${APP_PREFIX_DOC}/html")
          config_options+=("--pdfdir=${APP_PREFIX_DOC}/pdf")

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--program-suffix=")
          config_options+=("--with-pkgversion=${GCC_BRANDING}")

          config_options+=("--with-dwarf2")
          config_options+=("--with-stabs")
          config_options+=("--with-libiconv")
          config_options+=("--with-isl")
          config_options+=("--with-gnu-as")
          config_options+=("--with-gnu-ld")
          config_options+=("--with-diagnostics-color=auto")

          config_options+=("--without-system-zlib")

          config_options+=("--without-cuda-driver")

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

          # Support for Intel Memory Protection Extensions (MPX).
          # Fails on Mingw-w64. Not for Arm.
          # config_options+=("--enable-libmpx")
         
          config_options+=("--enable-libatomic")
          config_options+=("--enable-graphite")
          config_options+=("--enable-libquadmath")
          config_options+=("--enable-libquadmath-support")

          config_options+=("--enable-libstdcxx-visibility")
          config_options+=("--enable-libstdcxx-pch")

          # TODO
          # config_options+=("--enable-nls")

          config_options+=("--disable-multilib")
          config_options+=("--disable-libstdcxx-debug")

          # It is not yet clear why, but Arch, RH use it.
          # config_options+=("--disable-libunwind-exceptions")

          config_options+=("--disable-nls")
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

            config_options+=("--enable-libssp")
            config_options+=("--with-default-libstdcxx-abi=new")

            # From HomeBrew
            config_options+=("--enable-threads=posix")

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
            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")            
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

            config_options+=("--enable-libssp")
            config_options+=("--with-default-libstdcxx-abi=new")

            config_options+=("--enable-threads=posix")

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
            elif [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
            then
              config_options+=("--with-arch=i686")
              config_options+=("--with-arch-32=i686")
              config_options+=("--with-tune=generic")
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

            # config_options+=("--enable-languages=c,c++,lto")
            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")
            config_options+=("--enable-objc-gc=auto")

            # Used by Arch
            # config_options+=("--disable-libunwind-exceptions")
            # config_options+=("--disable-libssp")
            config_options+=("--with-linker-hash-style=gnu")
            config_options+=("--enable-clocale=gnu")

            config_options+=("--enable-default-pie")
            # config_options+=("--enable-default-ssp")

            # Not needed.
            # config_options+=("--with-sysroot=${APP_PREFIX}")
            # config_options+=("--with-native-system-header-dir=/usr/include")

          elif [ "${TARGET_PLATFORM}" == "win32" ]
          then

            config_options+=("--disable-shared")
            config_options+=("--disable-shared-libgcc")

            config_options+=("--enable-threads=posix")

            # config_options+=("--enable-languages=c,c++,lto")
            config_options+=("--enable-languages=c,c++,objc,obj-c++,fortran,lto")
            config_options+=("--enable-objc-gc=auto")

            config_options+=("--enable-mingw-wildcard")

            # Inspired from mingw-w64; no --with-sysroot
            config_options+=("--with-native-system-header-dir=${APP_PREFIX}/include")

            # https://stackoverflow.com/questions/15670169/what-is-difference-between-sjlj-vs-dwarf-vs-seh
            # The defaults are sjlj for 32-bit and seh for 64-bit, thus
            # better do not set anything explicitly, since disabling sjlj
            # fails on both 64/32-bit:
            # error: ‘__LIBGCC_EH_FRAME_SECTION_NAME__’ undeclared here
            # config_options+=("--disable-sjlj-exceptions")

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
            # Turn on symbol versioning in the shared library
            config_options+=("--disable-symvers")

            # msys2
            config_options+=("--with-default-libstdcxx-abi=gcc4-compatible")
            config_options+=("--disable-libitm")
            config_options+=("--enable-version-specific-runtime-libs")
            config_options+=("--with-tune=generic")

            # config_options+=("--disable-libssp")
            # msys2: --disable-libssp should suffice in GCC 8
            export gcc_cv_libc_provides_ssp=yes
            # libssp: conflicts with builtin SSP

            export lt_cv_deplibs_check_method='pass_all'

          else
            echo "Oops! Unsupported ${TARGET_PLATFORM}."
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

        if [ "${TARGET_PLATFORM}" == "darwin" ]
        then
          find "${APP_PREFIX}/lib" -name '*.dylib' ! -name 'libgcc_*' \
            -exec rm -fv {} \;

          rm -rf "${APP_PREFIX}/bin/gcc-ar"
          rm -rf "${APP_PREFIX}/bin/gcc-nm"
          rm -rf "${APP_PREFIX}/bin/gcc-ranlib"
        fi

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

  tests_add "test_gcc"
}

function test_gcc()
{
  echo
  echo "Testing the gcc binaries..."

  (
    show_libs "${APP_PREFIX}/bin/gcc"
    show_libs "${APP_PREFIX}/bin/g++"
    show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1)"
    show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=cc1plus)"
    show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=collect2)"
    show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto1)"
    show_libs "$(${APP_PREFIX}/bin/gcc --print-prog-name=lto-wrapper)"

    echo
    echo "Testing if gcc binaries start properly..."

    run_app "${APP_PREFIX}/bin/gcc" --version
    run_app "${APP_PREFIX}/bin/g++" --version

    if [ "${TARGET_PLATFORM}" != "darwin" ]
    then
      # On Darwin they refer to existing Darwin tools
      # which do not support --version
      run_app "${APP_PREFIX}/bin/gcc-ar" --version
      run_app "${APP_PREFIX}/bin/gcc-nm" --version
      run_app "${APP_PREFIX}/bin/gcc-ranlib" --version
    fi

    run_app "${APP_PREFIX}/bin/gcov" --version
    run_app "${APP_PREFIX}/bin/gcov-dump" --version
    run_app "${APP_PREFIX}/bin/gcov-tool" --version

    if [ -f "${APP_PREFIX}/bin/gfortran${DOTEXE}" ]
    then
      run_app "${APP_PREFIX}/bin/gfortran" --version
    fi

    echo
    echo "Showing configurations..."

    run_app "${APP_PREFIX}/bin/gcc" -v
    run_app "${APP_PREFIX}/bin/gcc" -dumpversion
    run_app "${APP_PREFIX}/bin/gcc" -dumpmachine
    run_app "${APP_PREFIX}/bin/gcc" -print-search-dirs
    run_app "${APP_PREFIX}/bin/gcc" -print-libgcc-file-name
    run_app "${APP_PREFIX}/bin/gcc" -print-multi-directory
    run_app "${APP_PREFIX}/bin/gcc" -print-multi-lib
    run_app "${APP_PREFIX}/bin/gcc" -print-multi-os-directory

    # Cannot run the the compiler without a loader.
    if true # [ "${TARGET_PLATFORM}" != "win32" ]
    then

      echo
      echo "Testing if gcc compiles simple Hello programs..."

      local tmp="$(mktemp ~/tmp/test-gcc-XXXXXXXXXX)"
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

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > hello.c
#include <stdio.h>

int
main(int argc, char* argv[])
{
  printf("Hello\n");

  return 0;
}
__EOF__

      # Test C compile and link in a single step.
      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -o hello-c1 hello.c

      test_expect "hello-c1" "Hello"

      # Test C compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/gcc" -o hello-c.o -c hello.c
      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -o hello-c2 hello-c.o

      test_expect "hello-c2" "Hello"

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -static-libgcc -o static-hello-c2 hello-c.o

      test_expect "static-hello-c2" "Hello"

      # Test LTO C compile and link in a single step.
      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -flto -o lto-hello-c1 hello.c

      test_expect "lto-hello-c1" "Hello"

      # Test LTO C compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/gcc" -flto -o lto-hello-c.o -c hello.c
      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -flto -o lto-hello-c2 lto-hello-c.o

      test_expect "lto-hello-c2" "Hello"

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -static-libgcc -flto -o static-lto-hello-c2 lto-hello-c.o

      test_expect "static-lto-hello-c2" "Hello"

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > hello.cpp
#include <iostream>

int
main(int argc, char* argv[])
{
  std::cout << "Hello" << std::endl;

  return 0;
}
__EOF__

      # Test C++ compile and link in a single step.
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -o hello-cpp1 hello.cpp

      test_expect "hello-cpp1" "Hello"

      # Test C++ compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/g++" -o hello-cpp.o -c hello.cpp
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -o hello-cpp2 hello-cpp.o

      test_expect "hello-cpp2" "Hello"

      # Note: macOS linker ignores -static-libstdc++
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -static-libgcc -static-libstdc++ -o static-hello-cpp2 hello-cpp.o

      test_expect "static-hello-cpp2" "Hello"

      # Test LTO C++ compile and link in a single step.
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -flto -o lto-hello-cpp1 hello.cpp

      test_expect "lto-hello-cpp1" "Hello"

      # Test LTO C++ compile and link in separate steps.
      run_app "${APP_PREFIX}/bin/g++" -flto -o lto-hello-cpp.o -c hello.cpp
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -flto -o lto-hello-cpp2 lto-hello-cpp.o

      test_expect "lto-hello-cpp2" "Hello"

      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -static-libgcc -static-libstdc++ -flto -o static-lto-hello-cpp2 lto-hello-cpp.o

      test_expect "static-lto-hello-cpp2" "Hello"

      # -----------------------------------------------------------------------

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

  return 0;
}
__EOF__

      # -O0 is an attempt to prevent any interferences with the optimiser.
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -o except -O0 except.cpp

      if [ "${TARGET_PLATFORM}" != "darwin" ]
      then
        # on Darwin: 'Symbol not found: __ZdlPvm'
        test_expect "except" "MyException"
      fi

      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -static-libgcc -static-libstdc++ -o static-except -O0 except.cpp

      test_expect "static-except" "MyException"

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

  return 0; 
}
__EOF__

      # -O0 is an attempt to prevent any interferences with the optimiser.
      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -o str-except -O0 str-except.cpp
      
      test_expect "str-except" "MyStringException"

      run_app "${APP_PREFIX}/bin/g++" ${VERBOSE_FLAG} -static-libgcc -static-libstdc++ -o static-str-except -O0 str-except.cpp

      test_expect "static-str-except" "MyStringException"

      # -----------------------------------------------------------------------
      # TODO: test creating libraries, static and shared.

      # -----------------------------------------------------------------------
      # Test Fortran.

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > fortran.f90
      integer,parameter::m=10000
      real::a(m), b(m)
      real::fact=0.5

      do concurrent (i=1:m)
        a(i) = a(i) + fact*b(i)
      end do
      write(*,"(A)") "Done"
      end
__EOF__

      run_app "${APP_PREFIX}/bin/gfortran" ${VERBOSE_FLAG} -o fortran -O0 fortran.f90

      test_expect "fortran" "Done"

      run_app "${APP_PREFIX}/bin/gfortran" ${VERBOSE_FLAG} -static-libgcc -static-libgfortran -o static-fortran -O0 fortran.f90

      test_expect "static-fortran" "Done"

      # -----------------------------------------------------------------------
      # Test Objective-C.

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > objc.m
#include <stdio.h>

int main(void)
{
  /* Not really Objective-C */
  printf("Hello World\n");
}
__EOF__

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -o objc -O0 objc.m 

      test_expect "objc" "Hello World"

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -static-libgcc -o static-objc -O0 objc.m 

      test_expect "static-objc" "Hello World"

      # -----------------------------------------------------------------------

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > add.c
// __declspec(dllexport)
int
add(int a, int b)
{
  return a + b;
}
__EOF__

      run_app "${APP_PREFIX}/bin/gcc" -o add.o -fpic -c add.c

      rm -rf libadd.a
      if [ "${TARGET_PLATFORM}" == "darwin" ]
      then
        run_app "ar" -r ${VERBOSE_FLAG} libadd-static.a add.o
        run_app "ranlib" libadd-static.a
      else
        run_app "${APP_PREFIX}/bin/ar" -r ${VERBOSE_FLAG} libadd-static.a add.o
        run_app "${APP_PREFIX}/bin/ranlib" libadd-static.a
      fi

      # No gcc-ar/gcc-ranlib on Darwin/mingw; problematic with clang.

      if [ "${TARGET_PLATFORM}" == "win32" ]
      then
        run_app "${APP_PREFIX}/bin/gcc" -o libadd-shared.dll -shared add.o -Wl,--subsystem,windows
      else
        run_app "${APP_PREFIX}/bin/gcc" -o libadd-shared.so -shared add.o
      fi

      # Note: __EOF__ is quoted to prevent substitutions here.
      cat <<'__EOF__' > adder.c
#include <stdio.h>
#include <stdlib.h>

extern int
add(int a, int b);

int
main(int argc, char* argv[])
{
  int sum = atoi(argv[1]) + atoi(argv[2]);
  printf("%d\n", sum);

  return 0;
}
__EOF__

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -o static-adder adder.c -ladd-static -L .

      test_expect "static-adder" "42" 40 2

      run_app "${APP_PREFIX}/bin/gcc" ${VERBOSE_FLAG} -o shared-adder adder.c -ladd-shared -L .

      (
        LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-""}
        export LD_LIBRARY_PATH=$(pwd):${LD_LIBRARY_PATH}
        test_expect "shared-adder" "42" 40 2
      )

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

      cd "${APP_PREFIX}"

      local libs=$(find "${APP_PREFIX}" -type f -name '*.[ao]')
      for lib in ${libs}
      do
        if is_elf "${lib}" || is_ar "${lib}"
        then
          echo "strip -S ${lib}"
          strip -S "${lib}"
        fi
      done
    )
  fi
}

# -----------------------------------------------------------------------------

function build_mingw() 
{
  # http://mingw-w64.org/doku.php/start
  # https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/

  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-headers
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-crt
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-winpthreads
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-binutils
  # https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=mingw-w64-gcc

  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-headers-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-crt-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-winpthreads-git/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-binutils/PKGBUILD
  # https://github.com/msys2/MINGW-packages/blob/master/mingw-w64-gcc/PKGBUILD
  
  # https://github.com/msys2/MSYS2-packages/blob/master/gcc/PKGBUILD

  # https://github.com/StephanTLavavej/mingw-distro

  # 2018-06-03, "5.0.4"
  # 2018-09-16, "6.0.0"
  # 2019-11-11, "7.0.0"
  # 2020-09-18, "8.0.0"
  # 2021-05-09, "8.0.2"

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

          # https://docs.microsoft.com/en-us/cpp/porting/modifying-winver-and-win32-winnt?view=msvc-160
          # Windows 7
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

        # mingw-w64 and Arch do this.
        # rm -fv "${APP_PREFIX}/include/pthread_signal.h"
        # rm -fv "${APP_PREFIX}/include/pthread_time.h"
        # rm -fv "${APP_PREFIX}/include/pthread_unistd.h"

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

      CPPFLAGS=""
      CFLAGS="-O2 -pipe -w"
      CXXFLAGS="-O2 -pipe -w"
      LDFLAGS=""

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS

      # Without it, apparently a bug in autoconf/c.m4, function AC_PROG_CC, results in:
      # checking for _mingw_mac.h... no
      # configure: error: Please check if the mingw-w64 header set and the build/host option are set properly.
      # (https://github.com/henry0312/build_gcc/issues/1)
      # export CC=""

      env | sort

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
          elif [ "${TARGET_ARCH}" == "x32" -o "${TARGET_ARCH}" == "ia32" ]
          then
            config_options+=("--enable-lib32")
            config_options+=("--disable-lib64")
          else
            echo "Oops! Unsupported ${TARGET_ARCH}."
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

      CPPFLAGS=""
      CFLAGS="-O2 -pipe -w"
      CXXFLAGS="-O2 -pipe -w"
      LDFLAGS=""

      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS
      export LDFLAGS
      
      env | sort

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
          # Avoid a reference to 'DLL Name: libwinpthread-1.dll'
          config_options+=("--disable-shared")

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
}

# -----------------------------------------------------------------------------
