part of '../../lsl_flutter.dart';

/// Domain class for stream information
class StreamInfo<S> {
  /// Name of the stream. Describes the device (or product series) that this stream makes available
  /// (for use by programs, experimenters or data analysts). Cannot be empty.
  String name;

  /// Content type of the stream. Please see https://github.com/sccn/xdf/wiki/Meta-Data (or web search for:
  /// XDF meta-data) for pre-defined content-type names, but you can also make up your own.
  /// The content type is the preferred way to find streams (as opposed to searching by name).
  String type;

  /// [channelCount] Number of channels per sample. This stays constant for the lifetime of the stream.
  int channelCount;

  /// [nominalSRate] The sampling rate (in Hz) as advertised by the data source, if regular (otherwise set to IRREGULAR_RATE).
  double nominalSRate;

  /// [channelFormat] Format/type of each channel.
  ChannelFormat<S> channelFormat;

  /// [sourceId] Unique identifier of the device or source of the data, if available (such as the serial number).
  /// This is critical for system robustness since it allows recipients to recover from failure even after the
  /// serving app, device or computer crashes (just by finding a stream with the same source id on the network again).
  /// Therefore, it is highly recommended to always try to provide whatever information can uniquely identify the data source itself.
  String sourceId;

  /// Properties generated by LSL

  /// Protocol version used to deliver the stream.
  int? version;

  /// Creation time stamp of the stream.
  double? createdAt;

  /// Unique ID of the stream outlet (once assigned).
  String? uid;

  /// Session ID for the given stream.
  String? sessionId;

  /// Hostname of the providing machine (once bound to an outlet).
  String? hostname;

  /// Constructor for a stream information object
  ///
  /// Note that channelFormat is a required parameter
  StreamInfo(this.name, this.type, this.channelFormat,
      [this.channelCount = 1, this.nominalSRate = 0, this.sourceId = ""]);
}
