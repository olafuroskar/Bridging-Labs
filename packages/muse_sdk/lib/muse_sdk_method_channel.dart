import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'muse_sdk_platform_interface.dart';

/// An implementation of [MuseSdkPlatform] that uses method channels.
class MethodChannelMuseSdk extends MuseSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('muse_sdk');

  static const _eventChannel = EventChannel('muse_sdk/events');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream<dynamic> getMuseEvents() {
    return _eventChannel.receiveBroadcastStream();
  }

  @override
  void initialize() async {
    await methodChannel.invokeMethod('initialize');
  }

  @override
  Future<bool> isBluetoothEnabled() async {
    final enabled =
        await methodChannel.invokeMethod<bool>('isBluetoothEnabled');
    return enabled ?? false;
  }

  @override
  void refreshMuseList() async {
    await methodChannel.invokeMethod('refreshMuseList');
  }

  @override
  Future<void> connect(int muse) async {
    await methodChannel.invokeMethod('connectToMuse', {'index': muse});
  }

  @override
  void disconnect() async {
    await methodChannel.invokeMethod('disconnectMuse');
  }
}
