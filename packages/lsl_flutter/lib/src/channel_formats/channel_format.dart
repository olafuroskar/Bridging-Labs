part of '../../lsl_flutter.dart';

/// An abstract class for all channel formats
abstract class ChannelFormat<T> {
  /// Gets the native channel format type
  lsl_channel_format_t get nativeChannelFormat;

  @override
  String toString();
}
