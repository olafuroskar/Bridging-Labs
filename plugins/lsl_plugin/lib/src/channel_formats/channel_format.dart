import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

abstract class ChannelFormat<T> {
  lsl_channel_format_t get nativeChannelFormat;

  @override
  String toString();
}
