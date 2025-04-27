import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:sensors/main.dart';

class OutletConfigDto {
  /// Device metadata - The type of stream, e.g. Polar device, Muse device, internal gyroscope etc.
  final StreamType streamType;

  /// Device metadata - id of the device.
  final int deviceId;

  /// The name of the stream to be created
  final String name;

  /// The type of the stream to be created, EEG, PPG, audio etc.
  final String type;

  /// The format of the data to be streamed from the outlet
  final ChannelFormat channelFormat;

  /// The number of data channels on the stream.
  final int channelCount;

  /// The nominal sampling rate of the stream.
  final double nominalSRate;

  /// A unique identifier for the stream.
  final String sourceId;

  /// The desired chunk granularity (in samples) for transmission.
  final int chunkSize;

  /// Optionally the maximum amount of data to buffer (in seconds if there is a nominal sampling rate,
  /// otherwise x100 in samples).
  final int maxBuffered;

  /// Whether LSL should provide the timestamps on push.
  final bool useLslTimestamps;

  /// The offset processing mode of sample timestamps.
  final OffsetMode mode;

  /// The interval in which offsets are calculated.
  final double offsetCalculationInterval;

  /// Whether an accompanying marker stream should be created with the main data stream.
  final bool createMarkerStream;

  const OutletConfigDto(
      {required this.name,
      required this.type,
      required this.streamType,
      required this.deviceId,
      required this.channelFormat,
      required this.channelCount,
      required this.nominalSRate,
      required this.sourceId,
      this.chunkSize = 0,
      this.maxBuffered = 360,
      required this.useLslTimestamps,
      this.mode = OffsetMode.none,
      this.offsetCalculationInterval = 5,
      this.createMarkerStream = false});
}
