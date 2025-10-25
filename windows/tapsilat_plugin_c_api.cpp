#include "tapsilat_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tapsilat_plugin.h"

void TapsilatPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  TapsilatPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
