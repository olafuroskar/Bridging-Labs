part of '../lsl_bindings.dart';

const String _libName = 'lsl_bindings';

/// The dynamic library in which the symbols for [LslBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('liblsl.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('lsl.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final LslBindings lslBindings = LslBindings(_dylib);
