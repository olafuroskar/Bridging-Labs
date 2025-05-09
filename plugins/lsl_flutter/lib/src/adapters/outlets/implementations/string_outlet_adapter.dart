part of '../outlets.dart';

class StringOutletAdapter extends OutletAdapter<String> {
  /// {@macro create}
  StringOutletAdapter._(Outlet<String> outlet) {
    final nativeOutlet = createOutlet(outlet, CftStringChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  void pushSample(List<String> sample,
      [Timestamp? timestamp, bool pushthrough = true]) {
    if (sample.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();
    final encodedStrings = sample.map(toString).toList();

    final nativeSamplePointer =
        malloc.allocate<Pointer<Char>>(sample.length * sizeOf<Pointer<Char>>());

    for (var i = 0; i < sample.length; i++) {
      nativeSamplePointer[i] = encodedStrings[i];
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_sample_strtp(outletPointer, nativeSamplePointer,
          timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings.lsl_push_sample_str(outletPointer, nativeSamplePointer);
    }

    for (var ptr in encodedStrings) {
      malloc.free(ptr);
    }
    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunk(List<List<String>> chunk,
      [Timestamp? timestamp, bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();

    final nativeSamplePointer =
        malloc.allocate<Pointer<Char>>(dataElements * sizeOf<Pointer<Char>>());

    for (var i = 0; i < chunkSize; i++) {
      final encodedStrings = chunk[i].map(toString).toList();
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = encodedStrings[j];
      }
    }

    if (timestamp != null) {
      lsl.bindings.lsl_push_chunk_strtp(outletPointer, nativeSamplePointer,
          dataElements, timestamp.toLslTime(), pushthrough ? 1 : 0);
    } else {
      lsl.bindings
          .lsl_push_chunk_str(outletPointer, nativeSamplePointer, dataElements);
    }

    malloc.free(nativeSamplePointer);
  }

  @override
  void pushChunkWithTimestamps(
      List<List<String>> chunk, List<Timestamp> timestamps,
      [bool pushthrough = true]) {
    if (chunk.isEmpty) {
      return;
    }

    final outletPointer = _outletContainer._nativeOutlet;

    final (dataElements, chunkSize, channelCount) = getDataElements(chunk);

    Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();

    final nativeSamplePointer =
        malloc.allocate<Pointer<Char>>(dataElements * sizeOf<Pointer<Char>>());

    for (var i = 0; i < chunkSize; i++) {
      final encodedStrings = chunk[i].map(toString).toList();
      for (var j = 0; j < channelCount; j++) {
        nativeSamplePointer[i * channelCount + j] = encodedStrings[j];
      }
    }

    final nativeTimestamps = allocatTimestamps(timestamps);

    lsl.bindings.lsl_push_chunk_strtnp(outletPointer, nativeSamplePointer,
        dataElements, nativeTimestamps, pushthrough ? 1 : 0);

    malloc.free(nativeSamplePointer);
    malloc.free(nativeTimestamps);
  }
}
