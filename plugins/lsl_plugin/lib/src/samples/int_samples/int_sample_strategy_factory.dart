import 'package:lsl_plugin/src/channel_formats/int_channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/int_samples/int_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/int_samples/long_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/int_samples/short_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';

class IntSampleStrategyFactory {
  /// A factory that generates the appropriate integer sample strategy based on [channelFormat]
  static SampleStrategy<int> sampleStrategyFor(
      lsl_outlet outlet, IntChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case Int8ChannelFormat():
        return ShortSampleStrategy(outlet, lsl);
      case Int16ChannelFormat():
        return ShortSampleStrategy(outlet, lsl);
      case Int32ChannelFormat():
        return IntSampleStrategy(outlet, lsl);
      case Int64ChannelFormat():
        return LongSampleStrategy(outlet, lsl);
    }
  }
}
