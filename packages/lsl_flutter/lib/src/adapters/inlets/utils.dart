import 'package:lsl_flutter/src/adapters/inlets/inlets.dart';

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
