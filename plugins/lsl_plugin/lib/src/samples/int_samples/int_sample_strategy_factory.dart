import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/int_samples/int_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/int_samples/long_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/int_samples/short_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';

class IntSampleStrategyFactory {
  /// A factory that generates the appropriate integer sample strategy based on [channelFormat]
  static SampleStrategy<int> sampleStrategyFor(
      lsl_outlet outlet, ChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case ChannelFormat.int8:
        return ShortSampleStrategy(outlet, lsl);
      case ChannelFormat.int16:
        return ShortSampleStrategy(outlet, lsl);
      case ChannelFormat.int32:
        return IntSampleStrategy(outlet, lsl);
      case ChannelFormat.int64:
        return LongSampleStrategy(outlet, lsl);
      default:
        throw Exception(
            "An int sample strategy can not be used with channel format ${channelFormat.toString()}");
    }
  }
}
