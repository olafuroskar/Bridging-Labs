import 'dart:async';
import 'dart:io';

import 'multicast_lock_platform_interface.dart';

class MulticastLock {
  Future<String?> getPlatformVersion() {
    return MulticastLockPlatform.instance.getPlatformVersion();
  }

  FutureOr<void> acquireMulticastLock() {
    if (Platform.isAndroid) {
      return MulticastLockPlatform.instance.acquireMulticastLock();
    }
  }

  FutureOr<void> releaseMulticastLock() {
    if (Platform.isAndroid) {
      return MulticastLockPlatform.instance.releaseMulticastLock();
    }
  }
}
