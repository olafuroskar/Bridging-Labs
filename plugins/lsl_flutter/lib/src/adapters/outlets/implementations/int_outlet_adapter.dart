part of '../outlets.dart';

class IntOutletAdapter extends OutletAdapter<int> {
  /// {@macro create}
  IntOutletAdapter._(Outlet<int> outlet) {
    final nativeOutlet = createOutlet(outlet, Int32ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  void pushSample(List<int> sample,
      [Timestamp? timestamp, bool pushthrough = true]) {
    if (sample.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;
    final nativeSamplePointer =
        malloc.allocate<Int32>(sample.length * sizeOf<Int32>());
    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = sample[i];
    }
    if (timestamp != null) {
      lsl.bindings.lsl_push_sample_itp(outletPointer, nativeSamplePointer,
          timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_i(outletPointer, nativeSamplePointer);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunk(List<List<int>> chunk,
      [Timestamp? timestamp, bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Int32>(dataElements * sizeOf<Int32>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_itp(outletPointer, nativeSamplePointer,
          dataElements, timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_i(outletPointer, nativeSamplePointer, dataElements);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunkWithTimestamps(
      List<List<int>> chunk, List<Timestamp> timestamps,
      [bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Int32>(dataElements * sizeOf<Int32>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_itnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
