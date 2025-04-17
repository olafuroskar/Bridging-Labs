import 'package:multicast_lock/multicast_lock.dart';
import 'package:lsl_bindings/lsl_bindings.dart';

/// A class encapsulating the bindings to the native functions in [_dylib], as well as multicast lock for Android
///
/// This is an interface for testing purposes
class Lsl {
  /// {@macro bindings}
  static final Lsl _singleton = Lsl._internal();

  static LslBindingsBindings _bindings = lslBindings;
  static MulticastLock _multicastLock = MulticastLock();

  factory Lsl() {
    return _singleton;
  }

  /// {@macro set_bindings}
  static void setBindings(LslBindingsBindings bindings) {
    _bindings = bindings;
  }

  static void setMulticastLock(MulticastLock multicastLock) {
    _multicastLock = multicastLock;
  }

  LslBindingsBindings get bindings => _bindings;

  MulticastLock get multicastLock => _multicastLock;

  Lsl._internal();
}

final lsl = Lsl();
