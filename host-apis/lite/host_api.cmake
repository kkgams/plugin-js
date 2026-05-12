add_library(host_api STATIC
  ${HOST_API}/host_api.cpp
  ${HOST_API}/bindings/bindings.c
  ${HOST_API}/bindings/bindings_component_type.o
)

target_link_libraries(host_api PRIVATE spidermonkey)

target_include_directories(host_api PUBLIC
  ${HOST_API}/include
  ${HOST_API}/bindings
)

# No preview1 adapter.
# No wasi-http.
# No wasi-sockets.
# No wasi-random.
# No wasi-filesystem.
