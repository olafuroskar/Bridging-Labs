part of '../../lsl_flutter.dart';

/// Represents all double channel formats
sealed class DoubleChannelFormat implements ChannelFormat<double> {
  const DoubleChannelFormat();
}

/// Represents a 32-bit float channel format
class Float32ChannelFormat extends DoubleChannelFormat {
  /// Creates a [Float32ChannelFormat] instance
  const Float32ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_float32;

  @override
  String toString() => "float32";
}

/// Represents a 32-bit float channel format
class Double64ChannelFormat extends DoubleChannelFormat {
  /// Creates a [Double64ChannelFormat] instance
  const Double64ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_double64;

  @override
  String toString() => "double64";
}
