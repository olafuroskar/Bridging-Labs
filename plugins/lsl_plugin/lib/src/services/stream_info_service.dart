import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/domain/stream_info.dart';

class StreamInfoService {
  StreamInfo<int> createIntStreamInfo(
      String name, String type, ChannelFormat<int> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  StreamInfo<double> createDoubleStreamInfo(
      String name, String type, ChannelFormat<double> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }

  StreamInfo<String> createStringStreamInfo(
      String name, String type, ChannelFormat<String> channelFormat,
      [int channelCount = 1, double nominalSRate = 0, String sourceId = ""]) {
    return StreamInfo(
        name, type, channelFormat, channelCount, nominalSRate, sourceId);
  }
}
