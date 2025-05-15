import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carp_multicast_lock/carp_multicast_lock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMulticastLock platform = MethodChannelMulticastLock();
  const MethodChannel channel = MethodChannel('carp_multicast_lock');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('acquireMulticastLock', () async {
    bool success;
    try {
      await platform.acquireMulticastLock();
      success = true;
    } catch (e) {
      success = false;
    }
    expect(success, true);
  });
}
