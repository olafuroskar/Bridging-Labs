import 'package:lsl_plugin/src/channel_formats/double_channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/double_samples/double_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/double_samples/float_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';

class DoubleSampleStrategyFactory {
  /// A factory that generates the appropriate integer sample strategy based on [channelFormat]
  static SampleStrategy<double> sampleStrategyFor(
      lsl_outlet outlet, DoubleChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case Float32ChannelFormat():
        return FloatSampleStrategy(outlet, lsl);
      case Double64ChannelFormat():
        return DoubleSampleStrategy(outlet, lsl);
    }
  }
}
