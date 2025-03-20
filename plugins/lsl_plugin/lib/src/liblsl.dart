import 'dart:ffi';
import 'dart:io';

import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

const String _libName = 'lsl_plugin';

/// The dynamic library in which the symbols for [TestFfiBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('liblsl.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

// /// An interface encapsulating the bindings to the native functions in [_dylib].
// ///
// /// This is an interface for testing purposes
// abstract class LslInterface {
//   LslPluginBindings get bindings;
// }

class Lsl {
  /// {@macro bindings}
  static final Lsl _singleton = Lsl._internal();

  static LslPluginBindings _bindings = LslPluginBindings(_dylib);
  static MulticastLock _multicastLock = MulticastLock();

  factory Lsl() {
    return _singleton;
  }

  /// {@macro set_bindings}
  static void setBindings(LslPluginBindings bindings) {
    _bindings = bindings;
  }

  static void setMulticastLock(MulticastLock multicastLock) {
    _multicastLock = multicastLock;
  }

  LslPluginBindings get bindings => _bindings;

  MulticastLock get multicastLock => _multicastLock;

  Lsl._internal();
}

final lsl = Lsl();
