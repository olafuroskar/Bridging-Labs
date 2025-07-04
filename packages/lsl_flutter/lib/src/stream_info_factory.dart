part of '../../lsl_flutter.dart';

/// Handles the creation of stream info objects depending on data type
///
/// Creating [StreamInfo] objects manually allows for dynamic typing of the channel format generic.
/// This is undesirable as it facilitates weak typing. Therefore users of the package are required to
/// create a stream info object through this service.
class StreamInfoFactory {
  /// Creates a stream info object with an integer channel format.
  ///
  /// See [StreamInfo] for parameters
  static StreamInfo<int> createIntStreamInfo(
      String name, String type, ChannelFormat<int> channelFormat,
      {int channelCount = 1, double nominalSRate = 0, String sourceId = ""}) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  /// Creates a stream info object with an double channel format.
  ///
  /// See [StreamInfo] for parameters
  static StreamInfo<double> createDoubleStreamInfo(
      String name, String type, ChannelFormat<double> channelFormat,
      {int channelCount = 1, double nominalSRate = 0, String sourceId = ""}) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  /// Creates a stream info object with an string channel format.
  ///
  /// See [StreamInfo] for parameters
  static StreamInfo<String> createStringStreamInfo(
      String name, String type, ChannelFormat<String> channelFormat,
      {int channelCount = 1, double nominalSRate = 0, String sourceId = ""}) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }
}
