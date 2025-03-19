import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/double_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/float_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/int_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/long_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/short_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlets/implementations/string_outlet_repository.dart';

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
