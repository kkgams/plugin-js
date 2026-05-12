#include <memory>
#include <string>
#include <string_view>

#include "encode.h"
#include "extension-api.h"
#include "starling_lite.h"

#include "js/CompilationAndEvaluation.h"
#include "js/SourceText.h"

api::Engine *engine;
static api::Engine *ENGINE = nullptr;

__attribute__((weak)) int main(int argc, const char *argv[]) {
  (void)argc;
  (void)argv;
  MOZ_ASSERT_UNREACHABLE("main() should not be called");
}

static void set_string(starling_lite_string_t *out, std::string_view value) {
  starling_lite_string_dup_n(out, value.data(), value.size());
}

static std::string pending_exception_to_string(JSContext *cx) {
  if (!JS_IsExceptionPending(cx)) {
    return "unknown JavaScript error";
  }

  JS::RootedValue exception(cx);
  if (!JS_GetPendingException(cx, &exception)) {
    JS_ClearPendingException(cx);
    return "unable to read pending JavaScript exception";
  }
  JS_ClearPendingException(cx);

  JS::RootedString str(cx, JS::ToString(cx, exception));
  if (!str) {
    JS_ClearPendingException(cx);
    return "unable to stringify JavaScript exception";
  }

  auto encoded = core::encode(cx, str);
  if (!encoded) {
    JS_ClearPendingException(cx);
    return "unable to encode JavaScript exception";
  }

  return std::string(encoded.begin(), encoded.end());
}

extern "C" bool exports_my_starling_lite_runtime_init(starling_lite_string_t *err) {
  (void)err;
  if (ENGINE) {
    return true;
  }

  auto config = std::make_unique<api::EngineConfig>();
  config->module_mode = false;
  config->debugging = false;

  ENGINE = new api::Engine(std::move(config));
  engine = ENGINE;
  return true;
}

extern "C" bool exports_my_starling_lite_runtime_eval(starling_lite_string_t *source,
                                                      starling_lite_string_t *ret,
                                                      starling_lite_string_t *err) {
  if (!ENGINE) {
    set_string(err, "runtime not initialized; call init() first");
    return false;
  }

  JSContext *cx = ENGINE->cx();
  JSAutoRealm ar(cx, ENGINE->global());

  JS::SourceText<mozilla::Utf8Unit> text;
  auto *chars = reinterpret_cast<const char *>(source->ptr);
  if (!text.init(cx, chars, source->len, JS::SourceOwnership::Borrowed)) {
    set_string(err, pending_exception_to_string(cx));
    return false;
  }

  JS::CompileOptions opts(cx);
  opts.setFileAndLine("<host-eval>", 1);

  JS::RootedValue result(cx);
  if (!JS::Evaluate(cx, opts, text, &result)) {
    set_string(err, pending_exception_to_string(cx));
    return false;
  }

  if (!ENGINE->run_event_loop()) {
    set_string(err, pending_exception_to_string(cx));
    return false;
  }

  JS::RootedString result_str(cx, JS::ToString(cx, result));
  if (!result_str) {
    set_string(err, pending_exception_to_string(cx));
    return false;
  }

  auto encoded = core::encode(cx, result_str);
  if (!encoded) {
    set_string(err, pending_exception_to_string(cx));
    return false;
  }

  set_string(ret, std::string_view(encoded.begin(), encoded.size()));
  return true;
}
