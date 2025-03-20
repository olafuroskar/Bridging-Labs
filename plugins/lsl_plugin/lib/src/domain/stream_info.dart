part of '../../lsl_plugin.dart';

class StreamInfo<S> {
  /// Properties provided by the user
  String name;
  String type;
  int channelCount;
  double nominalSRate;
  ChannelFormat<S> channelFormat;
  String sourceId;

  /// Propreties that LSL generates
  int? version;
  double? createdAt;
  String? uid;
  String? sessionId;
  String? hostname;

  /// Constructor for a stream information object
  ///
  /// Note that channelFormat is a required parameter
  StreamInfo(this.name, this.type, this.channelFormat,
      [this.channelCount = 1, this.nominalSRate = 0, this.sourceId = ""]);
}
