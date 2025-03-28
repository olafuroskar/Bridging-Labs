part of '../outlets.dart';

class FloatOutletAdapter extends OutletAdapter<double> {
  /// {@macro create}
  FloatOutletAdapter._(Outlet<double> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Double64ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  void pushSample(List<double> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

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
  }

  @override
  void pushChunk(List<List<double>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

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
  }

  @override
  void pushChunkWithTimestamps(
      List<List<double>> chunk, List<double> timestamps,
      [bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final dataElements = chunk.length;
    final channelCount = chunk[0].length;

    final nativeSamplePointer =
        malloc.allocate<Float>(dataElements * channelCount * sizeOf<Float>());
    for (var i = 0; i < dataElements; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * dataElements + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = utils.allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_ftnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
