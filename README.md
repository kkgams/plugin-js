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

If `just` is installed:

```sh
just build
```
