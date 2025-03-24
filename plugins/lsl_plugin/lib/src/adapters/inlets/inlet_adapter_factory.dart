part of 'inlets.dart';

class InletAdapterFactory {
  static InletAdapter<int> createIntAdapterFromStream(
      Inlet<int> inlet, ResolvedStream<int> stream) {
    switch (stream.info.channelFormat) {
      case Int8ChannelFormat():
      case Int16ChannelFormat():
      case Int32ChannelFormat():
      case Int64ChannelFormat():
        return IntInletAdapter._(inlet, stream);
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  static InletAdapter<double> createDoubleAdapterFromStream(
      Inlet<double> inlet, ResolvedStream<double> stream) {
    switch (stream.info.channelFormat) {
      case Float32ChannelFormat():
      case Double64ChannelFormat():
        throw UnimplementedError("Double unimplemented");
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }

  static InletAdapter<String> createStringAdapterFromStream(
      Inlet<String> inlet, ResolvedStream<String> stream) {
    switch (stream.info.channelFormat) {
      case CftStringChannelFormat():
        throw UnimplementedError("String unimplemented");
      default:
        throw Exception("Unsupported channel format for integers");
    }
  }
}
