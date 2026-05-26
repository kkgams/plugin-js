# gams-js plugin

Minimal SpiderMonkey-based JavaScript runner for the GAMS component-model runtime.

This repo builds one artifact:

```text
cmake-build-release/gams-js.wasm
```

The component exports `gams:js/js.run(source: string) -> result<string, string>` and imports only `gams:runtime/runtime@1.0.0`.

## Build

```sh
cmake -S . -B cmake-build-release -DCMAKE_BUILD_TYPE=Release
cmake --build cmake-build-release --parallel $(sysctl -n hw.ncpu) --target gams-js
```

Or use the Makefile wrapper:

```sh
make build
```

## Install from GHCR with `wkg`

Configure `wkg` to resolve the `gams` namespace from GHCR:

```toml
# ~/.config/wasm-pkg/config.toml

default_registry = "ghcr.io"

[namespace_registries]
gams = { registry = "gams-ghcr", metadata = { preferredProtocol = "oci", oci = { registry = "ghcr.io", namespacePrefix = "kkgams/" } } }
```

Then install the published component with the WIT package name:

```sh
wkg get gams:js@1.0.0 --output build.nosync/plugins/js.comp.wasm
```

This resolves to the canonical OCI package path `ghcr.io/kkgams/gams/js:1.0.0`.

The release workflow publishes only the canonical OCI package path, tagged as `1.0.0`, `latest`, and a UTC timestamp, for example:

```sh
wkg oci pull ghcr.io/kkgams/gams/js:<timestamp> -o build.nosync/plugins/js.comp.wasm
wkg oci pull ghcr.io/kkgams/gams/js:latest -o build.nosync/plugins/js.comp.wasm
```
