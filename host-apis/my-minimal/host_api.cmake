add_library(host_api STATIC
  ${HOST_API}/host_api.cpp
  ${HOST_API}/bindings/starling_lite.c
  ${HOST_API}/bindings/starling_lite_component_type.o
)

target_link_libraries(host_api PRIVATE spidermonkey)

target_include_directories(host_api PUBLIC
  ${HOST_API}/include
  ${HOST_API}/bindings
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  ${CMAKE_CURRENT_SOURCE_DIR}/runtime
  ${CMAKE_CURRENT_SOURCE_DIR}/deps/include
  ${CMAKE_CURRENT_SOURCE_DIR}/crates/rust-url
)

# starling-lite intentionally imports only my:starling-lite/host.{log, random-u32}.
# No WASI CLI, preview1 adapter, wasi:http, sockets, filesystem, or random APIs.
