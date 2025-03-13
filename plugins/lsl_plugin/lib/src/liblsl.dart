import 'dart:ffi';
import 'dart:io';

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

/// The bindings to the native functions in [_dylib].
// final LslPluginBindings bindings = LslPluginBindings(_dylib);

abstract class LslInterface {
  LslPluginBindings get bindings;
}

class Lsl implements LslInterface {
  static final Lsl _singleton = Lsl._internal();
  static final _bindings = LslPluginBindings(_dylib);

  factory Lsl() {
    return _singleton;
  }

  @override
  LslPluginBindings get bindings => _bindings;

  Lsl._internal();
}
