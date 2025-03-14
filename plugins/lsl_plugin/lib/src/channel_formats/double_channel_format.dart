import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

sealed class DoubleChannelFormat implements ChannelFormat {
  const DoubleChannelFormat();

  static const float32 = Float32ChannelFormat();
  static const double64 = Double64ChannelFormat();

  static const List<DoubleChannelFormat> formats = [
    float32,
    double64,
  ];
}

class Float32ChannelFormat extends DoubleChannelFormat {
  const Float32ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_float32;

  @override
  String toString() => "float32";
}

class Double64ChannelFormat extends DoubleChannelFormat {
  const Double64ChannelFormat();

  @override
  lsl_channel_format_t get nativeChannelFormat =>
      lsl_channel_format_t.cft_double64;

  @override
  String toString() => "double64";
}
