part of 'outlets.dart';

class OutletAdapterFactory {
  static OutletAdapter<int> createIntAdapterFromChannelFormat(
      Outlet<int> outlet) {
    switch (outlet.streamInfo.channelFormat) {
      case Int8ChannelFormat():
      case Int16ChannelFormat():
        return ShortOutletAdapter._(outlet);
      case Int32ChannelFormat():
        return IntOutletAdapter._(outlet);
      case Int64ChannelFormat():
        return LongOutletAdapter._(outlet);
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  static OutletAdapter<double> createDoubleAdapterFromChannelFormat(
      Outlet<double> outlet) {
    switch (outlet.streamInfo.channelFormat) {
      case Float32ChannelFormat():
        return FloatOutletAdapter._(outlet);
      case Double64ChannelFormat():
        return DoubleOutletAdapter._(outlet);
      default:
        throw Exception("Unsupported channel format for doubles");
    }
  }

  static OutletAdapter<String> createStringAdapterFromChannelFormat(
      Outlet<String> outlet) {
    switch (outlet.streamInfo.channelFormat) {
      case CftStringChannelFormat():
        return StringOutletAdapter._(outlet);
      default:
        throw Exception("Unsupported channel format for strings");
    }
  }
}
