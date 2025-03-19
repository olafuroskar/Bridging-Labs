import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/double_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/float_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/int_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/long_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/short_outlet_adapter.dart';
import 'package:lsl_plugin/src/adapters/outlets/implementations/string_outlet_adapter.dart';

class OutletAdapterFactory {
  static OutletAdapter<int> createIntRepositoryFromChannelFormat(
      ChannelFormat<int> channelFormat) {
    switch (channelFormat) {
      case Int8ChannelFormat():
      case Int16ChannelFormat():
        return ShortOutletAdapter();
      case Int32ChannelFormat():
        return IntOutletAdapter();
      case Int64ChannelFormat():
        return LongOutletAdapter();
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  static OutletAdapter<double> createDoubleRepositoryFromChannelFormat(
      ChannelFormat<double> channelFormat) {
    switch (channelFormat) {
      case Float32ChannelFormat():
        return FloatOutletAdapter();
      case Double64ChannelFormat():
        return DoubleOutletAdapter();
      default:
        throw Exception("Unsupported channel format for doubles");
    }
  }

  static OutletAdapter<String> createStringRepositoryFromChannelFormat(
      ChannelFormat<String> channelFormat) {
    switch (channelFormat) {
      case CftStringChannelFormat():
        return StringOutletAdapter();
      default:
        throw Exception("Unsupported channel format for strings");
    }
  }
}
