import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/utils.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class FloatOutletAdapter implements OutletAdapter<double> {
  lsl_outlet? _outletPointer;

  FloatOutletAdapter();

  @override
  Result<Unit> create(Outlet<double> outlet) {
    switch (createOutlet(outlet, Float32ChannelFormat())) {
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
  Result<Unit> pushSample(List<double> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      final nativeSamplePointer =
          malloc.allocate<Float>(sample.length * sizeOf<Float>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_ftp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_f(outletPointer, nativeSamplePointer);
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
  Result<Unit> pushChunk(List<List<double>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer =
          malloc.allocate<Float>(dataElements * channelCount * sizeOf<Float>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_ftp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings
            .lsl_push_chunk_f(outletPointer, nativeSamplePointer, dataElements);
      }
      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  @override
  Result<StreamInfo> getStreamInfo() {
    return getStreamInfo();
  }
}
