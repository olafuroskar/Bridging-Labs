part of 'outlets.dart';

lsl_outlet createOutlet<S>(Outlet<S> outlet, ChannelFormat<S> channelFormat) {
  lsl.acquireMulticastLock(outlet.streamInfo.name);

  final streamInfo = lsl.bindings.lsl_create_streaminfo(
      outlet.streamInfo.name.toNativeUtf8().cast<Char>(),
      outlet.streamInfo.type.toNativeUtf8().cast<Char>(),
      outlet.streamInfo.channelCount,
      outlet.streamInfo.nominalSRate,
      channelFormat.nativeChannelFormat,
      outlet.streamInfo.sourceId.toNativeUtf8().cast<Char>());

  return lsl.bindings
      .lsl_create_outlet(streamInfo, outlet.chunkSize, outlet.maxBuffered);
}

Pointer<Double> allocatTimestamps(List<Timestamp> timestamps) {
  final dataElements = timestamps.length;
  final nativeTimestampsPointer =
      malloc.allocate<Double>(dataElements * sizeOf<Double>());
  for (var i = 0; i < dataElements; i++) {
    nativeTimestampsPointer[i] = timestamps[i].toLslTime();
  }
  return nativeTimestampsPointer;
}

/// Returns the length of the data chunk when flattened
///
/// [chunk] The data to be sent
(int dataElements, int chunkSize, int channelCount) getDataElements(
    List<List<Object?>> chunk) {
  final chunkSize = chunk.length;
  final channelCount = chunk[0].length;
  // The number of elements LSL expects to be in this chunk
  final dataElements = chunkSize * channelCount;

  return (dataElements, chunkSize, channelCount);
}
