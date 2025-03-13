part of '../lsl_plugin.dart';

class StreamInfo {
  late final Pointer<lsl_streaminfo_struct_> _streamInfo;
  late final ChannelFormat _channelFormat;

  /// Construct a new streaminfo object.
  ///
  /// Core stream information is specified here. Any remaining meta-data can be added later.
  /// [name] Name of the stream.
  /// Describes the device (or product series) that this stream makes available
  /// (for use by programs, experimenters or data analysts). Cannot be empty.
  /// [type] Content type of the stream. Please see https://github.com/sccn/xdf/wiki/Meta-Data (or
  /// web search for: XDF meta-data) for pre-defined content-type names, but you can also make up your
  /// own. The content type is the preferred way to find streams (as opposed to searching by name).
  /// [channelCount] Number of channels per sample.
  /// This stays constant for the lifetime of the stream.
  /// [nominalSRate] The sampling rate (in Hz) as advertised by the
  /// datasource, if regular (otherwise set to #LSL_IRREGULAR_RATE).
  /// [channelFormat] Format/type of each channel.<br>
  /// If your channels have different formats, consider supplying multiple streams
  /// or use the largest type that can hold them all (such as #cft_double64).
  ///
  /// A good default is #cft_float32.
  /// [sourceId] Unique identifier of the source or device, if available (e.g. a serial number).
  /// Allows recipients to recover from failure even after the serving app or device crashes.
  /// May in some cases also be constructed from device settings.
  StreamInfo(String name, String type,
      [int channelCount = 8,
      double nominalSRate = 100,
      ChannelFormat channelFormat = ChannelFormat.float32,
      String sourceId = ""]) {
    final streamName = name.toNativeUtf8().cast<Char>();
    final streamType = type.toNativeUtf8().cast<Char>();
    final streamSourceId = sourceId.toNativeUtf8().cast<Char>();

    _streamInfo = bindings.lsl_create_streaminfo(streamName, streamType,
        channelCount, nominalSRate, channelFormat.value, streamSourceId);
  }

  /// Destroys the native stream info object
  void destroy() {
    bindings.lsl_destroy_streaminfo(_streamInfo);
  }

  /// Returns the native handle of the stream info object
  Pointer<lsl_streaminfo_struct_> handle() {
    return _streamInfo;
  }

  /// Returns the channel format of the stream info object
  ChannelFormat getChannelFormat() {
    return _channelFormat;
  }
}
