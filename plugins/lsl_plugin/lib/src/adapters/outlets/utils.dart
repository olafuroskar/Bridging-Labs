import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/stream_info.dart';

lsl_outlet createOutlet<S>(Outlet<S> outlet, ChannelFormat<S> channelFormat) {
  // Required on Android, TODO: Explain more...
  lsl.multicastLock.acquireMulticastLock();

  // print("Created outlet: ${outlet.streamInfo.channelCount}");

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

void destroy(lsl_outlet outlet) {
  final nativeInfo = lsl.bindings.lsl_get_info(outlet);
  lsl.bindings.lsl_destroy_outlet(outlet);
  lsl.bindings.lsl_destroy_streaminfo(nativeInfo);
  lsl.multicastLock.releaseMulticastLock();
}

StreamInfo getOutletStreamInfo(lsl_outlet outlet) {
  final nativeInfo = lsl.bindings.lsl_get_info(outlet);

  return getStreamInfo(nativeInfo);
}

bool haveConsumers(lsl_outlet outlet) {
  final result = lsl.bindings.lsl_have_consumers(outlet);
  return result > 0;
}

Future<bool> waitForConsumers(lsl_outlet outlet, double timeout) async {
  try {
    return await Isolate.run(() {
      return lsl.bindings.lsl_wait_for_consumers(outlet, timeout) > 0;
    });
  } catch (e) {
    return false;
  }
}

Pointer<Double> allocatTimestamps(List<double> timestamps) {
  final dataElements = timestamps.length;
  final nativeTimestampsPointer =
      malloc.allocate<Double>(dataElements * sizeOf<Double>());
  for (var i = 0; i < dataElements; i++) {
    nativeTimestampsPointer[i] = timestamps[i];
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
