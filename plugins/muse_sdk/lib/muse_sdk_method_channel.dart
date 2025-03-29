import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'muse_sdk_platform_interface.dart';

/// An implementation of [MuseSdkPlatform] that uses method channels.
class MethodChannelMuseSdk extends MuseSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('muse_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
