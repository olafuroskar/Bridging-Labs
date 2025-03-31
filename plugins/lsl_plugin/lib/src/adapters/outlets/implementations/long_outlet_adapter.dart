part of '../outlets.dart';

class LongOutletAdapter extends OutletAdapter<int> {
  /// {@macro create}
  LongOutletAdapter._(Outlet<int> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Int64ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  void pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final nativeSamplePointer =
        malloc.allocate<Int64>(sample.length * sizeOf<Int64>());
    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = sample[i];
    }
    if (timestamp != null) {
      lsl.bindings.lsl_push_sample_ltp(
          outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_l(outletPointer, nativeSamplePointer);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunk(List<List<int>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) =
        utils.getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Int64>(dataElements * sizeOf<Int64>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * chunkSize + j] = chunk[i][j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_ltp(outletPointer, nativeSamplePointer,
          dataElements, timestamp, pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_l(outletPointer, nativeSamplePointer, dataElements);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunkWithTimestamps(List<List<int>> chunk, List<double> timestamps,
      [bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) =
        utils.getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Int64>(dataElements * sizeOf<Int64>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * chunkSize + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = utils.allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_ltnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
