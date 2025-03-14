part of '../lsl_plugin.dart';

class StreamInfo<T extends ChannelFormat> {
  /// {@template bindings}
  /// Gets the Lsl singleton containing the native bindings
  ///
  /// In order to mock the native bindings we must use dependency injection. Therefore we wrap
  /// the bindings in an object. Furthermore, we do not want to call [DynamicLibrary.open] each time
  /// we instantiate the binding class, therefore we use a singleton.
  /// {@endtemplate}
  static LslInterface _lsl = Lsl();

  /// {@template set_bindings}
  /// Sets the LslInterface object. This is mainly done for testing purposes.
  /// {@endtemplate}
  static void setBindings(LslInterface lsl) {
    _lsl = lsl;
  }

  late final Pointer<lsl_streaminfo_struct_> _streamInfo;
  late final T _channelFormat;

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
  StreamInfo(String name, String type, T channelFormat,
      [int channelCount = 8, double nominalSRate = 100, String sourceId = ""]) {
    final streamName = name.toNativeUtf8().cast<Char>();
    final streamType = type.toNativeUtf8().cast<Char>();
    final streamSourceId = sourceId.toNativeUtf8().cast<Char>();
    _channelFormat = channelFormat;

    _streamInfo = _lsl.bindings.lsl_create_streaminfo(
        streamName,
        streamType,
        channelCount,
        nominalSRate,
        _channelFormat.nativeChannelFormat,
        streamSourceId);
  }

  /// Destroys the native stream info object
  void destroy() {
    _lsl.bindings.lsl_destroy_streaminfo(_streamInfo);
  }

  /// Returns the native handle of the stream info object
  Pointer<lsl_streaminfo_struct_> handle() {
    return _streamInfo;
  }

  /// Returns the channel format of the stream info object
  T getChannelFormat() {
    return _channelFormat;
  }
}
