# -----------------------------------------------------------------------------
# This file is part of the xPack distribution.
#   (https://xpack.github.io)
# Copyright (c) 2020 Liviu Ionescu.
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose is hereby granted, under the terms of the MIT license.
# -----------------------------------------------------------------------------

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
  # 2022-01-16, "11.2"
  # 2022-05-01, "12.1"

  local gdb_version="$1"

  local gdb_src_folder_name="gdb-${gdb_version}"

  local gdb_archive="${gdb_src_folder_name}.tar.xz"
  local gdb_url="https://ftp.gnu.org/gnu/gdb/${gdb_archive}"

  local gdb_folder_name="${gdb_src_folder_name}"

  mkdir -pv "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}"

  local gdb_stamp_file_path="${XBB_STAMPS_FOLDER_PATH}/stamp-${gdb_folder_name}-installed"

  if [ ! -f "${gdb_stamp_file_path}" ]
  then

    mkdir -pv "${XBB_SOURCES_FOLDER_PATH}"
    cd "${XBB_SOURCES_FOLDER_PATH}"

    # Download gdb
    if [ ! -d "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" ]
    then
      download_and_extract "${gdb_url}" "${gdb_archive}" \
        "${gdb_src_folder_name}"
    fi

    (
      mkdir -pv "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"
      cd "${XBB_BUILD_FOLDER_PATH}/${gdb_folder_name}"

      xbb_activate_dependencies_dev

      CPPFLAGS="${XBB_CPPFLAGS}"
      CFLAGS="${XBB_CFLAGS_NO_W}"
      CXXFLAGS="${XBB_CXXFLAGS_NO_W}"

      # LDFLAGS="${XBB_LDFLAGS_APP_STATIC_GCC}"
      LDFLAGS="${XBB_LDFLAGS_APP}"
      xbb_adjust_ldflags_rpath

      if [ "${XBB_HOST_PLATFORM}" == "win32" ]
      then
        # Used to enable wildcard; inspired from arm-none-eabi-gcc.
        LDFLAGS+=" -Wl,${XBB_NATIVE_DEPENDENCIES_INSTALL_FOLDER_PATH}/${XBB_TARGET_TRIPLET}/lib/CRT_glob.o"

        # Hack to place the bcrypt library at the end of the list of libraries,
        # to avoid 'undefined reference to BCryptGenRandom'.
        # Using LIBS does not work, the order is important.
        export DEBUGINFOD_LIBS="-lbcrypt"
      fi

      export CPPFLAGS
      export CFLAGS
      export CXXFLAGS

      export LDFLAGS
      export LIBS

      if [ ! -f "config.status" ]
      then
        (
          xbb_show_env_develop

          echo
          echo "Running gdb configure..."

          bash "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/gdb/configure" --help

          config_options=()

          config_options+=("--prefix=${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}")
          config_options+=("--program-suffix=")

          config_options+=("--infodir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/info")
          config_options+=("--mandir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/man")
          config_options+=("--htmldir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/html")
          config_options+=("--pdfdir=${XBB_LIBRARIES_INSTALL_FOLDER_PATH}/share/pdf")

          config_options+=("--build=${XBB_BUILD_TRIPLET}")
          config_options+=("--host=${XBB_HOST_TRIPLET}")
          config_options+=("--target=${XBB_TARGET_TRIPLET}")

          config_options+=("--with-pkgversion=${XBB_GDB_BRANDING}")

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

          if [ "${XBB_HOST_PLATFORM}" == "win32" ]
          then
            config_options+=("--disable-tui")
          else
            config_options+=("--enable-tui")
          fi

          config_options+=("--disable-werror")
          config_options+=("--enable-build-warnings=no")

          # Note that all components are disabled, except GDB.
          run_verbose bash ${DEBUG} "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}/configure" \
            ${config_options[@]}

          cp "config.log" "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/config-log-$(ndate).txt"
        ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/configure-output-$(ndate).txt"
      fi

      (
        echo
        echo "Running gdb make..."

        # Build.
        run_verbose make -j ${XBB_JOBS} all-gdb

        # install-strip fails, not only because of readline has no install-strip
        # but even after patching it tries to strip a non elf file
        # strip:.../install/riscv-none-gcc/bin/_inst.672_: file format not recognized
        run_verbose make install-gdb

        show_libs "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin/gdb"

      ) 2>&1 | tee "${XBB_LOGS_FOLDER_PATH}/${gdb_folder_name}/make-output-$(ndate).txt"

      copy_license \
        "${XBB_SOURCES_FOLDER_PATH}/${gdb_src_folder_name}" \
        "${gdb_folder_name}"

    )

    mkdir -pv "${XBB_STAMPS_FOLDER_PATH}"
    touch "${gdb_stamp_file_path}"

  else
    echo "Component gdb already installed."
  fi

  tests_add "test_gdb" "${XBB_EXECUTABLES_INSTALL_FOLDER_PATH}/bin"
}

function test_gdb()
{
  local test_bin_path="$1"

  show_libs "${test_bin_path}/gdb"

  run_app "${test_bin_path}/gdb" --version
  run_app "${test_bin_path}/gdb" --help
  run_app "${test_bin_path}/gdb" --config

  # This command is known to fail with 'Abort trap: 6' (SIGABRT)
  run_app "${test_bin_path}/gdb" \
    --nh \
    --nx \
    -ex='show language' \
    -ex='set language auto' \
    -ex='quit'

}

# -----------------------------------------------------------------------------
