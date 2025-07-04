part of '../../lsl_flutter.dart';

/// Represents all integer channel formats
sealed class IntChannelFormat implements ChannelFormat<int> {
  const IntChannelFormat();
}

/// Represents an 8-bit integer channel format
class Int8ChannelFormat extends IntChannelFormat {
  /// Creates an [Int8ChannelFormat] instance
  const Int8ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat => lsl_channel_format_t.cft_int8;

  @override
  String toString() => "int8";
}

/// Represents a 16-bit integer channel format
class Int16ChannelFormat extends IntChannelFormat {
  /// Creates an [Int16ChannelFormat] instance
  const Int16ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int16;

  @override
  String toString() => "int16";
}

/// Represents a 32-bit integer channel format
class Int32ChannelFormat extends IntChannelFormat {
  /// Creates an [Int32ChannelFormat] instance
  const Int32ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int32;

  @override
  String toString() => "int32";
}

/// Represents a 64-bit integer channel format
class Int64ChannelFormat extends IntChannelFormat {
  /// Creates an [Int64ChannelFormat] instance
  const Int64ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int64;

  @override
  String toString() => "int64";
}
