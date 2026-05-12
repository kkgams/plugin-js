#pragma once

#include <cstdint>
#include <string>
#include <vector>

namespace host_api {

struct Random {
  static uint32_t get_u32();
};

void log(std::string_view msg);

// Keep only if runtime/js.cpp or config parsing still expects args/env.
std::vector<std::string> environment_get_arguments();
std::optional<std::string> environment_get_variable(std::string_view name);

} // namespace host_api
