part of '../../lsl_flutter.dart';

abstract class ChannelFormat<T> {
  lsl_channel_format_t get nativeChannelFormat;

  @override
  String toString();
}
