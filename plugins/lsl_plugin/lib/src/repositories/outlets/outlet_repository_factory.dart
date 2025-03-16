import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/repositories/double_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/float_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/int_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/long_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/short_outlet_repository.dart';
import 'package:lsl_plugin/src/repositories/string_outlet_repository.dart';

class OutletRepositoryFactory {
  static OutletRepository<int> createIntRepositoryFromChannelFormat(
      ChannelFormat<int> channelFormat) {
    switch (channelFormat) {
      case Int8ChannelFormat():
      case Int16ChannelFormat():
        return ShortOutletRepository();
      case Int32ChannelFormat():
        return IntOutletRepository();
      case Int64ChannelFormat():
        return LongOutletRepository();
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  static OutletRepository<double> createDoubleRepositoryFromChannelFormat(
      ChannelFormat<double> channelFormat) {
    switch (channelFormat) {
      case Float32ChannelFormat():
        return FloatOutletRepository();
      case Double64ChannelFormat():
        return DoubleOutletRepository();
      default:
        throw Exception("Unsupported channel format for doubles");
    }
  }

  static OutletRepository<String> createStringRepositoryFromChannelFormat(
      ChannelFormat<String> channelFormat) {
    switch (channelFormat) {
      case CftStringChannelFormat():
        return StringOutletRepository();
      default:
        throw Exception("Unsupported channel format for strings");
    }
  }
}
