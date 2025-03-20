part of '../../lsl_plugin.dart';

/// Handles the creation of stream info objects depending on data type
///
/// Creating [StreamInfo] objects manually allows for dynamic typing of the channel format generic.
/// This is undesirable as it facilitates weak typing. Therefore users of the package are required to
/// create a stream info object through this service.
class StreamInfoFactory {
  static StreamInfo<int> createIntStreamInfo(
      String name, String type, ChannelFormat<int> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  static StreamInfo<double> createDoubleStreamInfo(
      String name, String type, ChannelFormat<double> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  static StreamInfo<String> createStringStreamInfo(
      String name, String type, ChannelFormat<String> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  // TODO: Add labels property on stream info: https://github.com/NeuropsyOL/RECORDA/blob/master/liblsl-Java/src/examples/HandleMetaData.java
  // https://github.com/NeuropsyOL/RECORDA/blob/09f68f48b73ad4936caa5cf937d6291b6e6efcb4/liblsl-Java/src/edu/ucsd/sccn/LSL.java#L292
}
