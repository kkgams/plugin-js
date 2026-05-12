#include "host_api.h"
#include "bindings.h"

namespace host_api {

uint32_t Random::get_u32() {
  // Call generated WIT import:
  //
  // my_starling_lite_host_random_u32()
  //
  // Exact generated name depends on wit-bindgen/c-bindgen output.
  return my_starling_lite_host_random_u32();
}

void log(std::string_view msg) {
  my_starling_lite_host_log(reinterpret_cast<const uint8_t *>(msg.data()), msg.size());
}

std::vector<std::string> environment_get_arguments() { return {}; }

std::optional<std::string> environment_get_variable(std::string_view name) { return std::nullopt; }

} // namespace host_api
