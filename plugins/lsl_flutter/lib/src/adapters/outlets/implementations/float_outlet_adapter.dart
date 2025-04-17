part of '../outlets.dart';

class FloatOutletAdapter extends OutletAdapter<double> {
  /// {@macro create}
  FloatOutletAdapter._(Outlet<double> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Double64ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  void pushSample(List<double> sample,
      [Timestamp? timestamp, bool pushthrough = true]) {
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
      lsl.bindings.lsl_push_sample_ftp(outletPointer, nativeSamplePointer,
          timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_f(outletPointer, nativeSamplePointer);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunk(List<List<double>> chunk,
      [Timestamp? timestamp, bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) =
        utils.getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Float>(dataElements * sizeOf<Float>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_ftp(outletPointer, nativeSamplePointer,
          dataElements, timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_f(outletPointer, nativeSamplePointer, chunkSize);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunkWithTimestamps(
      List<List<double>> chunk, List<Timestamp> timestamps,
      [bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) =
        utils.getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Float>(dataElements * sizeOf<Float>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = utils.allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_ftnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
