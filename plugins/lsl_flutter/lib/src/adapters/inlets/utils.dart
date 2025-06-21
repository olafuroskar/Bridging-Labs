import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/adapters/inlets/inlets.dart';
import 'package:lsl_flutter/src/adapters/utils.dart';
import 'package:lsl_flutter/src/liblsl.dart';
import 'package:lsl_flutter/src/utils/error_code.dart';
import 'package:lsl_flutter/src/utils/stream_info.dart';

/// {@macro open_stream}
void openStream(lsl_inlet inlet, double timeout) {
  // Allocate the memory needed on the heap
  final ec = malloc.allocate<Int32>(sizeOf<Int32>());

  lsl.bindings.lsl_open_stream(inlet, timeout, ec);

  checkError(ec);
  malloc.free(ec);
}

/// {@macro close_stream}
void closeStream(lsl_inlet inlet) {
  lsl.bindings.lsl_close_stream(inlet);
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
int samplesAvailable(lsl_inlet inlet) {
  return lsl.bindings.lsl_samples_available(inlet);
}

/// {@macro time_correction}
double timeCorrection(lsl_inlet inlet, double timeout) {
  // Allocate the memory needed on the heap
  final ec = malloc.allocate<Int32>(sizeOf<Int32>());
  final offset = lsl.bindings.lsl_time_correction(inlet, timeout, ec);

  checkError(ec);
  malloc.free(ec);

  return offset;
}

/// {@macro was_clock_reset}
bool wasClockReset(lsl_inlet inlet) {
  final clockWasReset = lsl.bindings.lsl_was_clock_reset(inlet);
  return clockWasReset == 1;
}

ErrorCode setPostProcessing(lsl_inlet inlet, List<ProcessingOptions> flags) {
  // Bitwise OR the elements of the flags list to get the desired postprocessing setting.
  final flagsValue = flags.fold(0, (prev, curr) => prev | curr.value);
  final code = lsl.bindings.lsl_set_postprocessing(inlet, flagsValue);
  return switch (code) {
    0 => ErrorCode.noError,
    -1 => ErrorCode.timeoutError,
    -2 => ErrorCode.lostError,
    -3 => ErrorCode.argumentError,
    -4 => ErrorCode.internalError,
    _ => ErrorCode.internalError
  };
}

(int, int) getBufferLengths(InletContainer inletContainer) {
  /// The default value of maxChunkLen is zero which allows the sender to determine granularity.
  /// However due to the fact that we need to allocate memory beforehand we set the value to 10.
  final maxChunkLen = inletContainer.inlet.maxChunkLen == 0
      ? 10
      : inletContainer.inlet.maxChunkLen;
  final dataBufferLength =
      inletContainer.inlet.streamInfo.channelCount * maxChunkLen;
  final timeStampBufferLength = maxChunkLen;

  return (dataBufferLength, timeStampBufferLength);
}
