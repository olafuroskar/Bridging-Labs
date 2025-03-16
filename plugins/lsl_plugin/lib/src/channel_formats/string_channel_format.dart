import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

sealed class StringChannelFormat implements ChannelFormat<String> {
  const StringChannelFormat();

  static const cftString = CftStringChannelFormat();

  static const List<StringChannelFormat> formats = [
    cftString,
  ];
}

class CftStringChannelFormat extends StringChannelFormat {
  const CftStringChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_string;

  @override
  String toString() => "string";
}
