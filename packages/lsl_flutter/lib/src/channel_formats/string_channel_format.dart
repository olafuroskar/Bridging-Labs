part of '../../lsl_flutter.dart';

/// Represents all string channel formats
sealed class StringChannelFormat implements ChannelFormat<String> {
  const StringChannelFormat();
}

/// Represents a string channel format
///
/// Cft just stands for channel format
class CftStringChannelFormat extends StringChannelFormat {
  /// Creates an [CftStringChannelFormat] instance
  const CftStringChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_string;

  @override
  String toString() => "string";
}
