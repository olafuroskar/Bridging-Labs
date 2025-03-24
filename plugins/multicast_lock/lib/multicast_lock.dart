import 'multicast_lock_platform_interface.dart';

class MulticastLock {
  Future<String?> getPlatformVersion() {
    return MulticastLockPlatform.instance.getPlatformVersion();
  }

  Future<void> acquireMulticastLock() {
    return MulticastLockPlatform.instance.acquireMulticastLock();
  }

  Future<void> releaseMulticastLock() {
    return MulticastLockPlatform.instance.releaseMulticastLock();
  }
}
