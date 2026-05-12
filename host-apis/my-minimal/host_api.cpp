#include "host_api.h"
#include "starling_lite.h"

namespace host_api {

Result<uint32_t> Random::get_u32() {
  return Result<uint32_t>::ok(my_starling_lite_host_random_u32());
}

void log(std::string_view msg) {
  starling_lite_string_t s{reinterpret_cast<uint8_t *>(const_cast<char *>(msg.data())), msg.size()};
  my_starling_lite_host_log(&s);
}

std::vector<std::string> environment_get_arguments() { return {}; }

std::optional<std::string> environment_get_variable(std::string_view) { return std::nullopt; }

} // namespace host_api
