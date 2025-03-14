import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/channel_formats/string_channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/string_samples/string_sample_strategy.dart';

class StringSampleStrategyFactory {
  /// A factory that generates the appropriate integer sample strategy based on [channelFormat]
  static SampleStrategy<String> sampleStrategyFor(
      lsl_outlet outlet, ChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case CftStringChannelFormat():
        return StringSampleStrategy(outlet, lsl);
      default:
        throw Exception(
            "An int sample strategy can not be used with channel format ${channelFormat.toString()}");
    }
  }
}
