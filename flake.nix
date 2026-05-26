{
  description = "starling-lite / GAMS JS runner development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Configure/build driver.
            cmake
            ninja
            gnumake

            # Host compiler/tooling used by CMake and SpiderMonkey fallback builds.
            clang
            llvm
            lld
            pkg-config

            # Rust is required by StarlingMonkey's Corrosion/Cargo crates.  The
            # CMake files call `rustup toolchain install` and `rustup target add`,
            # so provide rustup rather than only a fixed nixpkgs rustc.
            rustup

            # Fetch/unpack tools used by CMake/CPM and release artifact downloads.
            curl
            git
            cacert
            gnutar
            gzip
            xz
            unzip

            # Script/build helpers.
            bash
            python3
            perl
            nodejs

            # Useful component-model tools for local inspection/runs. CMake still
            # downloads pinned versions for the actual build where needed.
            wasmtime
            binaryen
          ];

          # Keep toolchain installs/cache local to the repository unless the user
          # overrides these variables before entering the shell.
          shellHook = ''
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            export RUSTUP_HOME="''${RUSTUP_HOME:-$PWD/.dev-tools/rustup}"
            export CARGO_HOME="''${CARGO_HOME:-$PWD/.dev-tools/cargo}"
            export CPM_SOURCE_CACHE="''${CPM_SOURCE_CACHE:-$PWD/deps/cpm_cache}"
            export PATH="$CARGO_HOME/bin:$PATH"

            echo "starling-lite dev shell"
            echo "  configure: cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release"
            echo "  build:     cmake --build cmake-build-release -t gams-js --parallel $(sysctl -n hw.ncpu 2>/dev/null || nproc 2>/dev/null || echo 4)"
            echo "  artifact:  cmake-build-release/gams-js.wasm"
          '';
        };
      });
    };
}
