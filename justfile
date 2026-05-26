ncpus := num_cpus()
mode := 'release'
builddir := justfile_directory() / 'cmake-build-' + mode

# Build the single GAMS JS plugin component.
build *flags:
    cmake -S . -B {{ builddir }} -DCMAKE_BUILD_TYPE={{ capitalize(mode) }} {{ flags }}
    cmake --build {{ builddir }} --parallel {{ ncpus }} --target gams-js

# Remove generated build output.
clean:
    rm -rf {{ builddir }}
