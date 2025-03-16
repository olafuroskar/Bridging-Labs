import 'package:lsl_plugin/src/channel_formats/channel_format.dart';

class StreamInfo<S> {
  String name;
  String type;
  int channelCount;
  double nominalSRate;
  ChannelFormat<S> channelFormat;
  String sourceId;

  /// Constructor for a stream information object
  ///
  /// Note that channelFormat is a required parameter
  StreamInfo(this.name, this.type, this.channelFormat,
      [this.channelCount = 1, this.nominalSRate = 0, this.sourceId = ""]);
}
