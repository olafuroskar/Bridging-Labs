import 'package:flutter_test/flutter_test.dart';
import 'package:carp_multicast_lock/carp_multicast_lock.dart';
import 'package:carp_multicast_lock/carp_multicast_lock_platform_interface.dart';
import 'package:carp_multicast_lock/carp_multicast_lock_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMulticastLockPlatform
    with MockPlatformInterfaceMixin
    implements MulticastLockPlatform {
  @override
  Future<void> acquireMulticastLock() {
    return Future.value();
  }

  @override
  Future<void> releaseMulticastLock() {
    return Future.value();
  }
}

void main() {
  final MulticastLockPlatform initialPlatform = MulticastLockPlatform.instance;

  test('$MethodChannelMulticastLock is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMulticastLock>());
  });

  test('acquireMulticastLock', () async {
    MulticastLock multicastLockPlugin = MulticastLock();
    MockMulticastLockPlatform fakePlatform = MockMulticastLockPlatform();
    MulticastLockPlatform.instance = fakePlatform;

    bool success;
    try {
      await multicastLockPlugin.acquireMulticastLock();
      success = true;
    } catch (e) {
      success = false;
    }
    expect(success, true);
  });
}
