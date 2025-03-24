import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/utils.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class StringOutletAdapter implements OutletAdapter<String> {
  lsl_outlet? _outletPointer;

  StringOutletAdapter();

  @override
  Result<Unit> create(Outlet<String> outlet) {
    switch (createOutlet(outlet, CftStringChannelFormat())) {
      case Ok(value: var nativeOutlet):
        _outletPointer = nativeOutlet;
        return Result.ok(unit);
      case Error(error: var e):
        return unexpectedError("$e");
    }
  }

  @override
  Result<Unit> destroy() {
    return destroyOutlet(
      _outletPointer,
    );
  }

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();
      final encodedStrings = sample.map(toString).toList();

      final nativeSamplePointer = malloc
          .allocate<Pointer<Char>>(sample.length * sizeOf<Pointer<Char>>());

      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = encodedStrings[i];
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_strtp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_str(outletPointer, nativeSamplePointer);
      }

      for (var ptr in encodedStrings) {
        malloc.free(ptr);
      }
      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  @override
  Result<Unit> pushChunk(List<List<String>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();

      final nativeSamplePointer = malloc.allocate<Pointer<Char>>(
          dataElements * channelCount * sizeOf<Pointer<Char>>());

      for (var i = 0; i < dataElements; i++) {
        final encodedStrings = chunk[i].map(toString).toList();
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = encodedStrings[j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_strtp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_chunk_str(
            outletPointer, nativeSamplePointer, dataElements);
      }

      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  @override
  Result<StreamInfo> getStreamInfo() {
    return getOutletStreamInfo(_outletPointer);
  }
}
