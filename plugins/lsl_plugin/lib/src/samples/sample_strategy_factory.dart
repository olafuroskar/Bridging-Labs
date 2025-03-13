import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/double_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/int_sample_strategy.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/string_sample_strategy.dart';

class SampleStrategyFactory {
  /// A factory that generates the appropriate sample strategy based on [channelFormat]
  static SampleStrategy sampleStrategyFor(
      lsl_outlet outlet, ChannelFormat channelFormat, LslInterface lsl) {
    switch (channelFormat) {
      case ChannelFormat.int8:
      case ChannelFormat.int16:
      case ChannelFormat.int32:
      case ChannelFormat.int64:
        return IntSampleStrategy(outlet, channelFormat, lsl);
      case ChannelFormat.float32:
      case ChannelFormat.double64:
        return DoubleSampleStrategy(outlet, channelFormat, lsl);
      case ChannelFormat.string:
        return StringSampleStrategy(outlet, channelFormat, lsl);
      default:
        // TODO: Undefined should maybe make a Custom Sample Strategy?
        throw Exception("TODO");
    }
  }
}
