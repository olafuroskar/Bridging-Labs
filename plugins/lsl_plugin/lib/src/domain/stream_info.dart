part of '../../lsl_plugin.dart';

class StreamInfo<S> {
  /// Construct a new [StreamInfo] object.
  ///
  /// {@template stream_info}
  /// Core stream information is specified here. Any remaining meta-data can be added later.
  /// [name] Name of the stream. Describes the device (or product series) that this stream makes available
  /// (for use by programs, experimenters or data analysts). Cannot be empty.
  /// [type] Content type of the stream. Please see https://github.com/sccn/xdf/wiki/Meta-Data (or web search for:
  /// XDF meta-data) for pre-defined content-type names, but you can also make up your own.
  /// The content type is the preferred way to find streams (as opposed to searching by name).
  /// [channelCount] Number of channels per sample. This stays constant for the lifetime of the stream.
  /// [nominalSRate] The sampling rate (in Hz) as advertised by the data source, if regular (otherwise set to IRREGULAR_RATE).
  /// [sourceId] Unique identifier of the device or source of the data, if available (such as the serial number).
  /// This is critical for system robustness since it allows recipients to recover from failure even after the
  /// serving app, device or computer crashes (just by finding a stream with the same source id on the network again).
  /// Therefore, it is highly recommended to always try to provide whatever information can uniquely identify the data source itself.
  /// {@endtemplate}
  /// [channelFormat] Format/type of each channel.
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
