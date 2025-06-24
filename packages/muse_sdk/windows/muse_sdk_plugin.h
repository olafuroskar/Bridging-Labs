#ifndef FLUTTER_PLUGIN_MUSE_SDK_PLUGIN_H_
#define FLUTTER_PLUGIN_MUSE_SDK_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace muse_sdk {

class MuseSdkPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MuseSdkPlugin();

  virtual ~MuseSdkPlugin();

  // Disallow copy and assign.
  MuseSdkPlugin(const MuseSdkPlugin&) = delete;
  MuseSdkPlugin& operator=(const MuseSdkPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace muse_sdk

#endif  // FLUTTER_PLUGIN_MUSE_SDK_PLUGIN_H_
