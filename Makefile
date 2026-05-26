.DEFAULT_GOAL := build

BUILD_TYPE ?= Release
BUILD_DIR ?= cmake-build-$(shell printf '%s' '$(BUILD_TYPE)' | tr '[:upper:]' '[:lower:]')
CMAKE_CONFIGURE_FLAGS ?=
CMAKE_BUILD_FLAGS ?=
NCPUS ?= $(shell sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)

ARTIFACT := $(BUILD_DIR)/gams-js.wasm
CMAKE_CACHE := $(BUILD_DIR)/CMakeCache.txt

PROJECT_INPUTS := \
	CMakeLists.txt \
	componentize.sh.in \
	rust-toolchain.toml \
	version.txt \
	$(shell find builtins cmake crates host-apis include runtime scripts -type f 2>/dev/null)

.PHONY: build configure clean reconfigure

# Build the single GAMS JS plugin component.
build: $(ARTIFACT)

# Configure the CMake build directory.
configure: $(CMAKE_CACHE)

$(CMAKE_CACHE): CMakeLists.txt $(shell find cmake host-apis -name '*.cmake' -type f 2>/dev/null)
	cmake -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) $(CMAKE_CONFIGURE_FLAGS)

$(ARTIFACT): $(CMAKE_CACHE) $(PROJECT_INPUTS)
	cmake --build $(BUILD_DIR) --parallel $(NCPUS) --target gams-js $(CMAKE_BUILD_FLAGS)

# Force a fresh CMake configure step without deleting downloaded dependencies.
reconfigure:
	rm -f $(CMAKE_CACHE)
	$(MAKE) configure

# Remove generated build output.
clean:
	rm -rf $(BUILD_DIR)
