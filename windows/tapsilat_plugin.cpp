#include "tapsilat_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include <string>
#include <sstream>

namespace {

const char kChannelName[] = "tapsilat";

std::string GetPlatformVersion() {
  std::ostringstream version_stream;
  version_stream << "Windows ";
  const auto version = ::GetVersion();
  const auto major = LOBYTE(LOWORD(version));
  const auto minor = HIBYTE(LOWORD(version));
  version_stream << static_cast<int>(major) << "." << static_cast<int>(minor);
  return version_stream.str();
}

}  // namespace

TapsilatPlugin::TapsilatPlugin() = default;

TapsilatPlugin::~TapsilatPlugin() = default;

void TapsilatPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_shared<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<TapsilatPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get(), channel](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

void TapsilatPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (call.method_name() == "getPlatformVersion") {
    result->Success(flutter::EncodableValue(GetPlatformVersion()));
    return;
  }

  result->NotImplemented();
}
