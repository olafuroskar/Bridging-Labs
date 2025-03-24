import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/utils.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class IntOutletAdapter implements OutletAdapter<int> {
  lsl_outlet? _outletPointer;

  IntOutletAdapter();

  @override
  Result<Unit> create(Outlet<int> outlet) {
    switch (createOutlet(outlet, Int32ChannelFormat())) {
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
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);
      final nativeSamplePointer =
          malloc.allocate<Int32>(sample.length * sizeOf<Int32>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_itp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_i(outletPointer, nativeSamplePointer);
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
  Result<Unit> pushChunk(List<List<int>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer =
          malloc.allocate<Int32>(dataElements * channelCount * sizeOf<Int32>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_itp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings
            .lsl_push_chunk_i(outletPointer, nativeSamplePointer, dataElements);
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
