{
  description = "GAMS JavaScript plugin development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # Project build entry points.
              cmake
              ninja
              gnumake

              # Native tools used by CMake/CPM and fallback source builds.
              clang
              llvm
              lld
              pkg-config
              git
              curl
              cacert
              python3
              perl
              nodejs

              # Rust is driven by cmake/init-corrosion.cmake via rustup.
              rustup

              # Archive tools for upstream binary releases fetched by CMake.
              gnutar
              gzip
              xz
              unzip

              # Handy local component/Wasm inspection tools. The CMake build still
              # fetches the pinned versions declared in cmake/*.cmake.
              wasmtime
              binaryen
              wasm-tools
            ];

            shellHook = ''
              export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
              export NIX_SSL_CERT_FILE="$SSL_CERT_FILE"

              # Keep toolchain state in the checkout by default, not in $HOME.
              export RUSTUP_HOME="''${RUSTUP_HOME:-$PWD/.dev-tools/rustup}"
              export CARGO_HOME="''${CARGO_HOME:-$PWD/.dev-tools/cargo}"
              export CPM_SOURCE_CACHE="''${CPM_SOURCE_CACHE:-$PWD/deps/cpm_cache}"
              export PATH="$CARGO_HOME/bin:$PATH"

              echo "gams-js dev shell"
              echo "  build:    make build"
              echo "  manual:   cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release && cmake --build cmake-build-release --target gams-js --parallel"
              echo "  artifact: cmake-build-release/gams-js.wasm"
            '';
          };
        });
    };
}
