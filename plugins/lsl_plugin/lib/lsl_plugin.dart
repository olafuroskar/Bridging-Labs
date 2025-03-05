import 'dart:ffi';
import 'dart:io';

import 'package:android_multicast_lock/android_multicast_lock.dart';

import 'lsl_plugin_bindings_generated.dart';
import 'package:ffi/ffi.dart';

class Outlet {
  Outlet(
    String streamName,
    String streamType,
    String streamSourceId,
  ) {
    final name = streamName.toNativeUtf8().cast<Char>();
    final type = streamType.toNativeUtf8().cast<Char>();
    final lsl_channel_format_t channelFormat = lsl_channel_format_t.cft_int32;
    final sourceId = streamSourceId.toNativeUtf8().cast<Char>();
    streamInfo = _bindings.lsl_create_streaminfo(
        name, type, 8, 100, channelFormat, sourceId);

    MulticastLock().acquire();
    outlet = _bindings.lsl_create_outlet(streamInfo, 0, 360);
  }

  late final Pointer<lsl_streaminfo_struct_> streamInfo;
  late final Pointer<lsl_outlet_struct_> outlet;
  bool _isDestroyed = false;

  void destroy() {
    _bindings.lsl_destroy_outlet(outlet);
    _bindings.lsl_destroy_streaminfo(streamInfo);
    MulticastLock().release();
    _isDestroyed = true;
  }

  bool isDestroyed() {
    return _isDestroyed;
  }

  void pushSample(List<double> sample) {
    final nativeSamplePointer =
        malloc.allocate<Float>(sample.length * sizeOf<Float>());

    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = sample[i];
    }

    _bindings.lsl_push_sample_f(outlet, nativeSamplePointer);

    malloc.free(nativeSamplePointer);
  }
}

const String _libName = 'lsl_plugin';

/// The dynamic library in which the symbols for [TestFfiBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
//    return DynamicLibrary.open('lib$_libName.so');
    return DynamicLibrary.open('liblsl.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final LslPluginBindings _bindings = LslPluginBindings(_dylib);
