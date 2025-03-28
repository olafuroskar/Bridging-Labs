import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/inlets/inlets.dart';
import 'package:lsl_plugin/src/adapters/utils.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/stream_info.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

/// {@macro open_stream}
Future<void> openStream(lsl_inlet inlet, double timeout) async {
  await Isolate.run(() {
    // Allocate the memory needed on the heap
    final ec = malloc.allocate<Int32>(sizeOf<Int32>());

    lsl.bindings.lsl_open_stream(inlet, timeout, ec);

    checkError(ec);
    malloc.free(ec);
  });
}

/// {@macro close_stream}
Result<Unit> closeStream(lsl_inlet inlet) {
  try {
    lsl.bindings.lsl_close_stream(inlet);
    return Result.ok(unit);
  } catch (e) {
    return unexpectedError("$e");
  }
}

/// {@macro close_stream}
StreamInfo getInletStreamInfo(lsl_inlet inlet, double timeout) {
  final ec = malloc.allocate<Int32>(sizeOf<Int32>());
  final nativeInfo = lsl.bindings.lsl_get_fullinfo(inlet, timeout, ec);

  checkError(ec);
  malloc.free(ec);

  return getStreamInfo(nativeInfo);
}

/// {@macro samples_available}
Result<int> samplesAvailable(lsl_inlet inlet) {
  try {
    final numAvailable = lsl.bindings.lsl_samples_available(inlet);
    return Result.ok(numAvailable);
  } catch (e) {
    return unexpectedError("$e");
  }
}

/// {@macro time_correction}
Future<double> timeCorrection(lsl_inlet inlet, double timeout) async {
  return await Isolate.run(() {
    // Allocate the memory needed on the heap
    final ec = malloc.allocate<Int32>(sizeOf<Int32>());
    final offset = lsl.bindings.lsl_time_correction(inlet, timeout, ec);

    checkError(ec);
    malloc.free(ec);

    return offset;
  });
}

/// {@macro was_clock_reset}
Result<bool> wasClockReset(lsl_inlet inlet) {
  try {
    final clockWasReset = lsl.bindings.lsl_was_clock_reset(inlet);
    return Result.ok(clockWasReset == 1);
  } catch (e) {
    return unexpectedError("$e");
  }
}

(int, int) getBufferLengths(InletContainer inletContainer) {
  /// The default value of maxChunkLen is zero which allows the sender to determine granularity.
  /// However due to the fact that we need to allocate memory beforehand we set the value to 10.
  final maxChunkLen = inletContainer.inlet.maxChunkLen == 0
      ? 10
      : inletContainer.inlet.maxChunkLen;
  final dataBufferLength =
      inletContainer.inlet.streamInfo.channelCount * maxChunkLen;
  final timeStampBufferLength = inletContainer.inlet.maxChunkLen;

  return (dataBufferLength, timeStampBufferLength);
}
