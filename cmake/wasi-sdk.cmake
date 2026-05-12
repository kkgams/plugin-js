set(WASI_SDK_VERSION 30 CACHE STRING "Version of wasi-sdk to use" FORCE)
set(WASI_SDK_PREFIX "" CACHE PATH "Path to an existing wasi-sdk installation")

# If the user already has wasi-sdk, allow either:
#   cmake -DWASI_SDK_PREFIX=/path/to/wasi-sdk ...
# or:
#   WASI_SDK_PATH=/path/to/wasi-sdk cmake ...
if(NOT WASI_SDK_PREFIX AND DEFINED ENV{WASI_SDK_PATH})
    set(WASI_SDK_PREFIX "$ENV{WASI_SDK_PATH}" CACHE PATH "Path to an existing wasi-sdk installation" FORCE)
endif()

if(WASI_SDK_PREFIX)
    cmake_path(ABSOLUTE_PATH WASI_SDK_PREFIX NORMALIZE)
else()
    string(REPLACE "aarch64" "arm64" WASI_SDK_ARCH ${HOST_CPU})
    set(WASI_SDK_URL "https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-${WASI_SDK_VERSION}/wasi-sdk-${WASI_SDK_VERSION}.0-${WASI_SDK_ARCH}-${HOST_OS}.tar.gz")
    message(STATUS "Downloading wasi-sdk from ${WASI_SDK_URL}")
    CPMAddPackage(NAME wasi-sdk URL ${WASI_SDK_URL})
    set(WASI_SDK_PREFIX ${CPM_PACKAGE_wasi-sdk_SOURCE_DIR})
endif()

set(CMAKE_TOOLCHAIN_FILE ${WASI_SDK_PREFIX}/share/cmake/wasi-sdk.cmake)

if(NOT EXISTS ${CMAKE_TOOLCHAIN_FILE})
    message(FATAL_ERROR "wasi-sdk toolchain file not found: ${CMAKE_TOOLCHAIN_FILE}\n"
        "Either install wasi-sdk and pass -DWASI_SDK_PREFIX=/path/to/wasi-sdk, set WASI_SDK_PATH, "
        "or delete a corrupt CPM cache entry and re-run configure. For the in-repo cache, try:\n"
        "  rm -rf ${CMAKE_CURRENT_SOURCE_DIR}/deps/cpm_cache/wasi-sdk")
endif()
