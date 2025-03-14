import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/double_samples/double_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/double_samples/float_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';

class DoubleSampleStrategyFactory {
  /// A factory that generates the appropriate integer sample strategy based on [channelFormat]
  static SampleStrategy<double> sampleStrategyFor(
      lsl_outlet outlet, ChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case ChannelFormat.float32:
        return FloatSampleStrategy(outlet, lsl);
      case ChannelFormat.double64:
        return DoubleSampleStrategy(outlet, lsl);
      default:
        throw Exception(
            "An int sample strategy can not be used with channel format ${channelFormat.toString()}");
    }
  }
}
