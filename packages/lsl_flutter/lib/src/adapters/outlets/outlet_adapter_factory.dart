part of 'outlets.dart';

/// A factory class for generating the appropriate outlet adapter based on channel format
class OutletAdapterFactory {
  /// Creates the appropriate integer outlet adapter based on the channel format
  ///
  /// The provided outlet's channel must be an integer format.
  ///
  /// [outlet] An outlet object containing the necessary meta-data to create an outlet and stream.
  static OutletAdapter<int> createIntAdapterFromChannelFormat(
      Outlet<int> outlet) {
    switch (outlet.streamInfo.channelFormat) {
      case Int8ChannelFormat():
        return CharOutletAdapter._(outlet);
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

  /// Creates the appropriate double outlet adapter based on the channel format
  ///
  /// The provided outlet's channel must be an double format.
  ///
  /// [outlet] An outlet object containing the necessary meta-data to create an outlet and stream.
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

  /// Creates the appropriate string outlet adapter based on the channel format
  ///
  /// The provided outlet's channel must be an string format.
  ///
  /// [outlet] An outlet object containing the necessary meta-data to create an outlet and stream.
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
