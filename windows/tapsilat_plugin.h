#ifndef FLUTTER_PLUGIN_TAPSILAT_PLUGIN_H_
#define FLUTTER_PLUGIN_TAPSILAT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

class TapsilatPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TapsilatPlugin();
  ~TapsilatPlugin() override;

  TapsilatPlugin(const TapsilatPlugin &) = delete;
  TapsilatPlugin &operator=(const TapsilatPlugin &) = delete;

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

#endif  // FLUTTER_PLUGIN_TAPSILAT_PLUGIN_H_
