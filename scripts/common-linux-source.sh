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

function do_kernel_headers()
{
  # https://www.kernel.org/pub/linux/kernel/
  # https://mirrors.edge.kernel.org/pub/linux/kernel/v3.x/linux-3.2.99.tar.xz

  # https://archlinuxarm.org/packages/any/linux-api-headers/files/PKGBUILD

  # 14-Feb-2018 "3.2.99"

  KERNEL_HEADERS_VERSION="$1"

  local kernel_headers_version_major="$(echo ${KERNEL_HEADERS_VERSION} | sed -e 's|\([0-9][0-9]*\)\..*|\1|')"
  local kernel_headers_version_minor="$(echo ${KERNEL_HEADERS_VERSION} | sed -e 's|\([0-9][0-9]*\)\.\([0-9][0-9]*\).*|\2|')"

  local kernel_headers_src_folder_name="linux-${KERNEL_HEADERS_VERSION}"
  local kernel_headers_folder_name="linux-headers-${KERNEL_HEADERS_VERSION}"

  local kernel_headers_archive="${kernel_headers_src_folder_name}.tar.xz"
  local kernel_headers_url="https://mirrors.edge.kernel.org/pub/linux/kernel/v${kernel_headers_version_major}.x/${kernel_headers_archive}"

  local kernel_headers_stamp_file_path="${INSTALL_FOLDER_PATH}/stamp-kernel-headers-${KERNEL_HEADERS_VERSION}-installed"
  if [ ! -f "${kernel_headers_stamp_file_path}" ]
  then

    # In-source build.
    cd "${BUILD_FOLDER_PATH}"

    download_and_extract "${kernel_headers_url}" "${kernel_headers_archive}" "${kernel_headers_src_folder_name}"

    (
      cd "${BUILD_FOLDER_PATH}/${kernel_headers_src_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${kernel_headers_folder_name}"

      xbb_activate
      xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      LDFLAGS="${XBB_LDFLAGS_APP}" 
      if [ "${IS_DEVELOP}" == "y" ]
      then
        LDFLAGS+=" -v"
      fi

      make mrproper
      make headers_check

      make INSTALL_HDR_PATH="${APP_PREFIX}/usr" headers_install

      # Weird files not needed.
      rm -f "${APP_PREFIX}/usr/include/..install.cmd"
      rm -f "${APP_PREFIX}/usr/include/.install"

      copy_license \
        "${BUILD_FOLDER_PATH}/${kernel_headers_src_folder_name}" \
        "${kernel_headers_folder_name}"

    )

    touch "${kernel_headers_stamp_file_path}"
  else
    echo "Component kernel headers already installed."
  fi
}

# -----------------------------------------------------------------------------

# Installs in a separate location compared to the other libs.

function do_glibc()
{
  # https://www.gnu.org/software/libc/
  # https://sourceware.org/glibc/wiki/FAQ
  # https://www.glibc.org/history.html
  # https://ftp.gnu.org/gnu/glibc
  # https://ftp.gnu.org/gnu/glibc/glibc-2.31.tar.xz

  # https://archlinuxarm.org/packages/aarch64/glibc/files
  # https://archlinuxarm.org/packages/aarch64/glibc/files/PKGBUILD

  # 2018-02-01 "2.27"
  # 2018-08-01 "2.28"
  # 2019-01-31 "2.29"
  # 2019-08-01 "2.30"
  # 2020-02-01 "2.31"

  local glibc_version="$1"
  local kernel_version="$2"

  # The folder name as resulted after being extracted from the archive.
  local glibc_src_folder_name="glibc-${glibc_version}"
  # The folder name for build, licenses, etc.
  local glibc_folder_name="${glibc_src_folder_name}"

  local glibc_archive="${glibc_src_folder_name}.tar.xz"
  local glibc_url="https://ftp.gnu.org/gnu/glibc/${glibc_archive}"

  local glibc_patch_file_name="glibc-${glibc_version}.patch"
  local glibc_stamp_file_path="${STAMPS_FOLDER_PATH}/stamp-glibc-${glibc_version}-installed"
  if [ ! -f "${glibc_stamp_file_path}" ]
  then

    cd "${SOURCES_FOLDER_PATH}"

    download_and_extract "${glibc_url}" "${glibc_archive}" \
      "${glibc_src_folder_name}" "${glibc_patch_file_name}"

    (
      mkdir -pv "${LIBS_BUILD_FOLDER_PATH}/${glibc_folder_name}"
      cd "${LIBS_BUILD_FOLDER_PATH}/${glibc_folder_name}"

      mkdir -pv "${LOGS_FOLDER_PATH}/${glibc_folder_name}"

      xbb_activate
      # Do not do this, glibc is more or less standalone.
      # gmp headers from the real gmp will crash the build.
      # xbb_activate_installed_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"
      LDFLAGS="${XBB_LDFLAGS_LIB}"
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
          echo
          echo "Running glibc configure..."

          bash "${SOURCES_FOLDER_PATH}/${glibc_src_folder_name}/configure" --help

          config_options=()

          # config_options+=("--prefix=${INSTALL_FOLDER_PATH}/glibc")

          config_options+=("--prefix=${APP_PREFIX}/usr")

          # Install the manual together with the rest.
          config_options+=("--infodir=${APP_PREFIX_DOC}/info")

          # Actually not used, PDF copied manually.
          config_options+=("--mandir=${APP_PREFIX_DOC}/man")
          config_options+=("--htmldir=${APP_PREFIX_DOC}/html")
          config_options+=("--pdfdir=${APP_PREFIX_DOC}/pdf")

          # From Arch:
          #  - Don't --enable-static-pie, broken on ARM
          #  - Don't --enable-cet, x86 only

          # --with-pkgversion=VERSION

          config_options+=("--build=${BUILD}")
          config_options+=("--host=${HOST}")
          config_options+=("--target=${TARGET}")

          config_options+=("--with-pkgversion=${GLIBC_BRANDING}")

          # Fails with 
          # fatal error: asm/prctl.h: No such file or directory
          # config_options+=("--with-headers=/usr/include")

          config_options+=("--enable-kernel=${kernel_version}")
          config_options+=("--enable-add-ons")
          config_options+=("--enable-bind-now")
          config_options+=("--enable-lock-elision")
          config_options+=("--enable-stack-protector=strong")
          config_options+=("--enable-stackguard-randomization")

          config_options+=("--disable-multi-arch")
          config_options+=("--disable-profile")
          config_options+=("--disable-werror")
          config_options+=("--disable-all-warnings")

          config_options+=("--disable-build-nscd")
          config_options+=("--disable-timezone-tools")

          bash ${DEBUG} "${SOURCES_FOLDER_PATH}/${glibc_src_folder_name}/configure" \
            ${config_options[@]}
            
          cp "config.log" "${LOGS_FOLDER_PATH}/${glibc_folder_name}/config-log.txt"
        ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${glibc_folder_name}/configure-output.txt"
      fi

      (
        echo
        echo "Running glibc make..."

        # Build.
        make -j ${JOBS}

        if [ "${WITH_TESTS}" == "y" ]
        then
          : # make check
        fi

        # The presence of this folder is chekced if configured as sysroot.
        mkdir -pv "${APP_PREFIX}/usr/include"

        if false
        then
          cp -rv /usr/include/* "${APP_PREFIX}/usr/include"
        fi

        # make install-strip
        make install

        (
          xbb_activate_tex

          # Full build, with documentation.
          if [ "${WITH_PDF}" == "y" ]
          then
            make pdf

            # make install-pdf
            mkdir -p "${APP_PREFIX_DOC}/pdf"
            cp -v manual/*.pdf "${APP_PREFIX_DOC}/pdf"
          fi

          if [ "${WITH_HTML}" == "y" ]
          then
            make html
            # make install-html
            echo "TODO: install glibc html"
            exit 1
          fi

        )

      ) 2>&1 | tee "${LOGS_FOLDER_PATH}/${glibc_folder_name}/make-output.txt"

      copy_license \
        "${SOURCES_FOLDER_PATH}/${glibc_src_folder_name}" \
        "${glibc_folder_name}"

    )
    touch "${glibc_stamp_file_path}"

  else
    echo "Library glibc already installed."
  fi
}

# -----------------------------------------------------------------------------
