part of '../outlets.dart';

class DoubleOutletAdapter extends OutletAdapter<double> {
  /// {@template create}
  /// Creates an outlet stream from the given [outlet] object
  /// {@endtemplate}
  DoubleOutletAdapter._(Outlet<double> outlet) {
    final nativeOutlet = createOutlet(outlet, Double64ChannelFormat());
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
        malloc.allocate<Double>(sample.length * sizeOf<Double>());
    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = sample[i];
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_sample_dtp(outletPointer, nativeSamplePointer,
          timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_d(outletPointer, nativeSamplePointer);
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

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Double>(dataElements * sizeOf<Double>());

    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_dtp(outletPointer, nativeSamplePointer,
          dataElements, timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_d(outletPointer, nativeSamplePointer, dataElements);
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

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    final nativeSamplePointer =
        malloc.allocate<Double>(dataElements * sizeOf<Double>());
    for (var i = 0; i < chunkSize; i++) {
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = chunk[i][j];
      }
    }

    final nativeTimestampsPointer = allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_dtnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestampsPointer, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestampsPointer);
  }
}
