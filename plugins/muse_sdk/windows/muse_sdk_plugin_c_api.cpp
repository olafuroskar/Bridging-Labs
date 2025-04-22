#include "include/muse_sdk/muse_sdk_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "muse_sdk_plugin.h"

void MuseSdkPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  muse_sdk::MuseSdkPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
