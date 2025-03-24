import 'package:flutter_test/flutter_test.dart';
import 'package:multicast_lock/multicast_lock.dart';
import 'package:multicast_lock/multicast_lock_platform_interface.dart';
import 'package:multicast_lock/multicast_lock_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMulticastLockPlatform
    with MockPlatformInterfaceMixin
    implements MulticastLockPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> acquireMulticastLock() {
    // TODO: implement acquireMulticastLock
    throw UnimplementedError();
  }

  @override
  Future<void> releaseMulticastLock() {
    // TODO: implement releaseMulticastLock
    throw UnimplementedError();
  }
}

void main() {
  final MulticastLockPlatform initialPlatform = MulticastLockPlatform.instance;

  test('$MethodChannelMulticastLock is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMulticastLock>());
  });

  test('getPlatformVersion', () async {
    MulticastLock multicastLockPlugin = MulticastLock();
    MockMulticastLockPlatform fakePlatform = MockMulticastLockPlatform();
    MulticastLockPlatform.instance = fakePlatform;

    expect(await multicastLockPlugin.getPlatformVersion(), '42');
  });
}
