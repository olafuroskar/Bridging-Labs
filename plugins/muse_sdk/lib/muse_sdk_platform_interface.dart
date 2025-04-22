import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'muse_sdk_method_channel.dart';

abstract class MuseSdkPlatform extends PlatformInterface {
  /// Constructs a MuseSdkPlatform.
  MuseSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static MuseSdkPlatform _instance = MethodChannelMuseSdk();

  /// The default instance of [MuseSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelMuseSdk].
  static MuseSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MuseSdkPlatform] when
  /// they register themselves.
  static set instance(MuseSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Stream<dynamic> getMuseEvents() {
    throw UnimplementedError('getMuseEvents() has not been implemented.');
  }

  void initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> isBluetoothEnabled() {
    throw UnimplementedError('isBluetoothEnabled() has not been implemented.');
  }

  void refreshMuseList() {
    throw UnimplementedError('refreshMuseList() has not been implemented.');
  }

  Future<void> connect(int muse) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  void disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }
}
