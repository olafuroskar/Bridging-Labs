import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

sealed class IntChannelFormat implements ChannelFormat {
  const IntChannelFormat();

  static const int8 = Int8ChannelFormat();
  static const int16 = Int16ChannelFormat();
  static const int32 = Int32ChannelFormat();
  static const int64 = Int64ChannelFormat();

  static const List<IntChannelFormat> formats = [int8, int16, int32, int64];
}

class Int8ChannelFormat extends IntChannelFormat {
  const Int8ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat => lsl_channel_format_t.cft_int8;

  @override
  String toString() => "int8";
}

class Int16ChannelFormat extends IntChannelFormat {
  const Int16ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int16;

  @override
  String toString() => "int16";
}

class Int32ChannelFormat extends IntChannelFormat {
  const Int32ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int32;

  @override
  String toString() => "int32";
}

class Int64ChannelFormat extends IntChannelFormat {
  const Int64ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_int64;

  @override
  String toString() => "int64";
}
