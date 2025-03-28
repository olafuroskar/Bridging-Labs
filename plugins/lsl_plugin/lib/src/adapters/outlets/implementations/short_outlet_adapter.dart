part of '../outlets.dart';

class ShortOutletAdapter extends OutletAdapter<int> {
  /// {@macro create}
  ShortOutletAdapter._(Outlet<int> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Int16ChannelFormat());
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
        malloc.allocate<Int16>(sample.length * sizeOf<Int16>());
    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = sample[i];
    }
    if (timestamp != null) {
      lsl.bindings.lsl_push_sample_stp(
          outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_s(outletPointer, nativeSamplePointer);
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

    final dataElements = chunk.length;
    final channelCount = chunk[0].length;

    final nativeSamplePointer =
        malloc.allocate<Int16>(dataElements * channelCount * sizeOf<Int16>());
    for (var i = 0; i < dataElements; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * dataElements + j] = chunk[i][j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_stp(outletPointer, nativeSamplePointer,
          dataElements, timestamp, pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_s(outletPointer, nativeSamplePointer, dataElements);
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

    final dataElements = chunk.length;
    final channelCount = chunk[0].length;

    final nativeSamplePointer =
        malloc.allocate<Int16>(dataElements * channelCount * sizeOf<Int16>());
    for (var i = 0; i < dataElements; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * dataElements + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = utils.allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_stnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
