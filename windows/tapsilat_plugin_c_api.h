#ifndef FLUTTER_PLUGIN_TAPSILAT_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_TAPSILAT_PLUGIN_C_API_H_

#include <flutter/plugin_registrar_windows.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

extern "C" FLUTTER_PLUGIN_EXPORT void TapsilatPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

#endif  // FLUTTER_PLUGIN_TAPSILAT_PLUGIN_C_API_H_
