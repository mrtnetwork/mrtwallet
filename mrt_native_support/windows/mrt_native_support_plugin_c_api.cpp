#include "include/mrt_native_support/mrt_native_support_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "mrt_native_support_plugin.h"

void MrtNativeSupportPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  mrt_native_support::MrtNativeSupport::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
