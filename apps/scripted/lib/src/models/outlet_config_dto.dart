import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:scripted/main.dart';

class OutletConfigDto {
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

  /// Device metadata - The type of stream, either random data or sine-wave
  final StreamType streamType;

  /// Sine-wave amplitude
  final double amplitude;

  /// Sine-wave wavelength
  final double wavelength;

  const OutletConfigDto({
    required this.name,
    required this.type,
    required this.channelFormat,
    required this.channelCount,
    required this.nominalSRate,
    required this.sourceId,
    this.chunkSize = 0,
    this.maxBuffered = 360,
    this.streamType = StreamType.random,
    this.amplitude = 1,
    this.wavelength = 1,
  });
}
