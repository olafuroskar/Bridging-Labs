import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'multicast_lock_platform_interface.dart';

/// An implementation of [MulticastLockPlatform] that uses method channels.
class MethodChannelMulticastLock extends MulticastLockPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('multicast_lock');

  @override
  Future<void> acquireMulticastLock() async {
    await methodChannel.invokeMethod<void>('acquireMulticastLock');
  }

  @override
  Future<void> releaseMulticastLock() async {
    await methodChannel.invokeMethod<void>('releaseMulticastLock');
  }
}
