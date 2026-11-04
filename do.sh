#!/usr/bin/env bash
set -euo pipefail

# NOTE: TOOLCHAIN_HOST_PLATFORM might need further adjustments in the actual
# config file of a toolchain, in case of architectures like aarch64 which can
# be referred as arm64, for example.
TOOLCHAIN_HOST_PLATFORM="$(uname -m)"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_DIR="${PROJECT_DIR}/src/platform"
BUILD_ROOT="${PROJECT_DIR}/build"
TOOLCHAINS_DIR="${BUILD_ROOT}/toolchains"

# ------------------------------------------------------------
# Help
# ------------------------------------------------------------

usage() {
    cat <<EOF
Usage:
    $0 <command> [options]

Commands:

    build <platform>
        Build the specified platform.
        Downloads the toolchain automatically if necessary.

    download <platform>
        Download and extract the toolchain for a platform.
        Does not configure or build the project.

    clean all
        Remove all platform build directories and all toolchains.

    clean platforms
        Remove all platform build directories.
        Keep downloaded toolchains.

    clean toolchains
        Remove all downloaded toolchains.
        Keep platform build directories.

    clean platform <platform>
        Remove the build directory for a specific platform.

    clean toolchain <platform>
        Remove the toolchain for a specific platform.

    help
        Display this help message.

Examples:

    $0 build linux
    $0 build windows

    $0 download linux

    $0 clean all
    $0 clean platforms
    $0 clean toolchains
    $0 clean platform linux
    $0 clean toolchain windows

Directory layout:

    build/
    ├── toolchains/
    │   └── <platform>/
    └── <platform>/

EOF
}

# ------------------------------------------------------------
# Platform configuration
# ------------------------------------------------------------

load_platform_config() {
    local platform="$1"

    PLATFORM_DIR_PATH="${PLATFORM_DIR}/${platform}"
    CONFIG_FILE="${PLATFORM_DIR_PATH}/toolchain.conf"

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "Error: Platform configuration not found: ${CONFIG_FILE}" >&2
        exit 1
    fi

    # Load platform-specific toolchain settings.
    source "${CONFIG_FILE}"

    # Validate required settings.
    : "${TOOLCHAIN_VERSION:?Missing TOOLCHAIN_VERSION in ${CONFIG_FILE}}"
    : "${TOOLCHAIN_ARCHIVE:?Missing TOOLCHAIN_ARCHIVE in ${CONFIG_FILE}}"
    : "${TOOLCHAIN_URL:?Missing TOOLCHAIN_URL in ${CONFIG_FILE}}"
    : "${TOOLCHAIN_PREFIX:?Missing TOOLCHAIN_PREFIX in ${CONFIG_FILE}}"

    PLATFORM="$platform"

    BUILD_DIR="${BUILD_ROOT}/${PLATFORM}"
    TOOLCHAIN_DIR="${TOOLCHAINS_DIR}/${PLATFORM}"
    TOOLCHAIN_ROOT="${TOOLCHAIN_DIR}/${TOOLCHAIN_ARCHIVE}"
    TOOLCHAIN_BIN="${TOOLCHAIN_ROOT}/bin"
}

# ------------------------------------------------------------
# Toolchain management
# ------------------------------------------------------------

toolchain_exists() {
    [[ -x "${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-gcc" &&
       -x "${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-g++" ]]
}

download_toolchain() {
    if toolchain_exists; then
        echo "Toolchain already installed for ${PLATFORM}."
        echo "Version: ${TOOLCHAIN_VERSION}"
        return
    fi

    echo "Downloading toolchain ${TOOLCHAIN_VERSION} for ${PLATFORM}..."

    mkdir -p "${TOOLCHAIN_DIR}"

    local archive_path="${TOOLCHAIN_DIR}/${TOOLCHAIN_ARCHIVE}.tar.xz"
    local temp_archive="${archive_path}.tmp"

    # Clean up an interrupted download.
    rm -f "${temp_archive}"

    curl --fail --location --retry 3 \
        "${TOOLCHAIN_URL}" \
        -o "${temp_archive}"

    mv "${temp_archive}" "${archive_path}"

    echo "Extracting toolchain..."

    tar -xJf "${archive_path}" -C "${TOOLCHAIN_DIR}"

    rm -f "${archive_path}"

    # Verify extraction.
    if ! toolchain_exists; then
        echo "Error: Toolchain extraction failed or archive layout differs from expected." >&2
        exit 1
    fi

    echo "Toolchain successfully installed."
}

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

build_platform() {
    local PLATFORM="$1"

    load_platform_config "${PLATFORM}"

    echo "========================================"
    echo "Building platform: ${PLATFORM}"
    echo "Toolchain version: ${TOOLCHAIN_VERSION}"
    echo "========================================"

    # Download toolchain if necessary.
    download_toolchain

    # Initialize platform-specific submodules.
    if command -v git >/dev/null 2>&1; then
        echo "Initializing platform submodules..."

        git -C "${PLATFORM_DIR_PATH}" submodule update --init --recursive
    else
        echo "Error: Git is not installed or not available in PATH." >&2
        exit 1
    fi

    # Configure CMake.
    echo "Configuring CMake..."

    cmake -S "${PROJECT_DIR}/src" -B "${BUILD_DIR}" \
        -DCMAKE_C_COMPILER="${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-gcc" \
        -DCMAKE_CXX_COMPILER="${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-g++" \
        -DCMAKE_ASM_COMPILER="${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-gcc" \
        -DCMAKE_OBJCOPY="${TOOLCHAIN_BIN}/${TOOLCHAIN_PREFIX}-objcopy" \
        -DCMAKE_PLATFORM="${PLATFORM}"

    # Build.
    echo "Building..."

    cmake --build "${BUILD_DIR}"

    echo "========================================"
    echo "Build completed successfully: ${PLATFORM}"
    echo "========================================"
}

# ------------------------------------------------------------
# Clean helpers
# ------------------------------------------------------------

clean_all_platforms() {
    echo "Cleaning all platform build directories..."

    if [[ -d "${PLATFORM_DIR}" ]]; then
        for config in "${PLATFORM_DIR}"/*/toolchain.conf; do
            [[ -f "${config}" ]] || continue

            local platform
            platform="$(basename "$(dirname "${config}")")"

            rm -rf -- "${BUILD_ROOT:?}/${platform}"

            echo "Removed platform build: ${platform}"
        done
    fi
}

clean_all_toolchains() {
    echo "Cleaning all downloaded toolchains..."

    if [[ -d "${TOOLCHAINS_DIR}" ]]; then
        rm -rf -- "${TOOLCHAINS_DIR}"
    fi

    echo "All toolchains removed."
}

clean_platform() {
    local platform="$1"

    load_platform_config "${platform}"

    echo "Cleaning platform build: ${PLATFORM}"

    rm -rf -- "${BUILD_DIR}"
}

clean_toolchain() {
    local platform="$1"

    load_platform_config "${platform}"

    echo "Cleaning toolchain: ${PLATFORM}"

    rm -rf -- "${TOOLCHAIN_DIR}"
}

# ------------------------------------------------------------
# Command dispatch
# ------------------------------------------------------------

COMMAND="${1:-help}"

case "${COMMAND}" in

    build)
        if [[ $# -ne 2 ]]; then
            usage
            exit 1
        fi

        build_platform "$2"
        ;;

    download)
        if [[ $# -ne 2 ]]; then
            usage
            exit 1
        fi

        load_platform_config "$2"
        download_toolchain
        ;;

    clean)
        if [[ $# -lt 2 ]]; then
            usage
            exit 1
        fi

        case "$2" in
            all)
                [[ $# -eq 2 ]] || { usage; exit 1; }

                clean_all_platforms
                clean_all_toolchains
                ;;

            platforms)
                [[ $# -eq 2 ]] || { usage; exit 1; }

                clean_all_platforms
                ;;

            toolchains)
                [[ $# -eq 2 ]] || { usage; exit 1; }

                clean_all_toolchains
                ;;

            platform)
                [[ $# -eq 3 ]] || { usage; exit 1; }

                clean_platform "$3"
                ;;

            toolchain)
                [[ $# -eq 3 ]] || { usage; exit 1; }

                clean_toolchain "$3"
                ;;

            *)
                usage
                exit 1
                ;;
        esac
        ;;

    help|-h|--help)
        usage
        ;;

    *)
        echo "Error: Unknown command '${COMMAND}'." >&2
        echo
        usage
        exit 1
        ;;

esac
