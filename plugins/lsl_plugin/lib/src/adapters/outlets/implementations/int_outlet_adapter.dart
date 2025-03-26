part of '../outlets.dart';

class IntOutletAdapter extends OutletAdapter<int> {
  /// {@macro create}
  IntOutletAdapter._(Outlet<int> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Int32ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = _outletContainer._nativeOutlet;
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
      final outletPointer = _outletContainer._nativeOutlet;

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
  Result<Unit> pushChunkWithTimestamps(
      List<List<int>> chunk, List<double> timestamps,
      [bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = _outletContainer._nativeOutlet;

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer =
          malloc.allocate<Int32>(dataElements * channelCount * sizeOf<Int32>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      final nativeTimestampsPointer = utils.allocatTimestamps(timestamps);

      lsl.bindings.lsl_push_chunk_itnp(outletPointer, nativeSamplePointer,
          dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

      malloc.free(nativeSamplePointer);
      malloc.free(nativeTimestampsPointer);

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
