import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'multicast_lock_method_channel.dart';

abstract class MulticastLockPlatform extends PlatformInterface {
  /// Constructs a MulticastLockPlatform.
  MulticastLockPlatform() : super(token: _token);

  static final Object _token = Object();

  static MulticastLockPlatform _instance = MethodChannelMulticastLock();

  /// The default instance of [MulticastLockPlatform] to use.
  ///
  /// Defaults to [MethodChannelMulticastLock].
  static MulticastLockPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MulticastLockPlatform] when
  /// they register themselves.
  static set instance(MulticastLockPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> acquireMulticastLock() {
    throw UnimplementedError(
        'acquireMulticastLock() has not been implemented.');
  }

  Future<void> releaseMulticastLock() {
    throw UnimplementedError(
        'releaseMulticastLock() has not been implemented.');
  }
}
