part of 'inlets.dart';

/// A factory class for creating [InletManager]s from an [Inlet] and a [ResolvedStream]
class InletAdapterFactory {
  /// Creates an [InletManager] with the relevant integer channel format given an [inlet] and a [stream]
  static InletAdapter<int> createIntAdapterFromStream(
      Inlet<int> inlet, ResolvedStream stream) {
    switch (stream.info.channelFormat) {
      case Int8ChannelFormat():
        return CharInletAdapter._(inlet, stream);
      case Int16ChannelFormat():
        return ShortInletAdapter._(inlet, stream);
      case Int32ChannelFormat():
        return IntInletAdapter._(inlet, stream);
      case Int64ChannelFormat():
        return LongInletAdapter._(inlet, stream);
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  /// Creates an [InletManager] with the relevant double channel format given an [inlet] and a [stream]
  static InletAdapter<double> createDoubleAdapterFromStream(
      Inlet<double> inlet, ResolvedStream stream) {
    switch (stream.info.channelFormat) {
      case Float32ChannelFormat():
        return FloatInletAdapter._(inlet, stream);
      case Double64ChannelFormat():
        return DoubleInletAdapter._(inlet, stream);
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  /// Creates an [InletManager] with the relevant string channel format given an [inlet] and a [stream]
  static InletAdapter<String> createStringAdapterFromStream(
      Inlet<String> inlet, ResolvedStream stream) {
    switch (stream.info.channelFormat) {
      case CftStringChannelFormat():
        return StringInletAdapter._(inlet, stream);
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }
}
