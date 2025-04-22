import 'package:flutter_test/flutter_test.dart';
import 'package:muse_sdk/muse_sdk.dart';
import 'package:muse_sdk/muse_sdk_platform_interface.dart';
import 'package:muse_sdk/muse_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMuseSdkPlatform
    with MockPlatformInterfaceMixin
    implements MuseSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Stream getMuseEvents() {
    // TODO: implement getMuseEvents
    throw UnimplementedError();
  }

  @override
  void initialize() {
    // TODO: implement initialize
  }

  @override
  Future<bool> isBluetoothEnabled() {
    // TODO: implement isBluetoothEnabled
    throw UnimplementedError();
  }

  @override
  void refreshMuseList() {
    // TODO: implement refreshMuseList
  }

  @override
  Future<void> connect(int muse) async {
    // TODO: implement connect
  }

  @override
  void disconnect() {
    // TODO: implement disconnect
  }
}

void main() {
  final MuseSdkPlatform initialPlatform = MuseSdkPlatform.instance;

  test('$MethodChannelMuseSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMuseSdk>());
  });

  test('getPlatformVersion', () async {
    MuseSdk museSdkPlugin = MuseSdk();
    MockMuseSdkPlatform fakePlatform = MockMuseSdkPlatform();
    MuseSdkPlatform.instance = fakePlatform;

    expect(await museSdkPlugin.getPlatformVersion(), '42');
  });
}
