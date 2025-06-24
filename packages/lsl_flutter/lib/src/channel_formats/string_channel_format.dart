part of '../../lsl_flutter.dart';

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
