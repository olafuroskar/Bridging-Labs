import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/channel_formats/channel_format.dart';
import 'package:lsl_flutter/src/liblsl.dart';

/// Maps a native [lsl_channel_format_t] to the corresponding [ChannelFormat] class
StreamInfo getStreamInfoFromChannelFormat(
    lsl_channel_format_t channelFormat,
    String name,
    String type,
    int channelCount,
    double nominalSrate,
    String sourceId) {
  return switch (channelFormat) {
    lsl_channel_format_t.cft_int8 => StreamInfo<int>(
        name, type, Int8ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_int16 => StreamInfo<int>(
        name, type, Int16ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_int32 => StreamInfo<int>(
        name, type, Int32ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_int64 => StreamInfo<int>(
        name, type, Int64ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_double64 => StreamInfo<double>(name, type,
        Double64ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_float32 => StreamInfo<double>(name, type,
        Float32ChannelFormat(), channelCount, nominalSrate, sourceId),
    lsl_channel_format_t.cft_string => StreamInfo<String>(name, type,
        CftStringChannelFormat(), channelCount, nominalSrate, sourceId),
    _ => throw Exception("Unsupported channel format")
  };
}

/// Extracts the information from a native [lsl_streaminfo] object to a [StreamInfo] object
StreamInfo getStreamInfo(lsl_streaminfo nativeInfo) {
  // User defined
  final name = lsl.bindings.lsl_get_name(nativeInfo);
  final type = lsl.bindings.lsl_get_type(nativeInfo);
  final channelCount = lsl.bindings.lsl_get_channel_count(nativeInfo);
  final nominalSrate = lsl.bindings.lsl_get_nominal_srate(nativeInfo);
  final nativeChannelFormat = lsl.bindings.lsl_get_channel_format(nativeInfo);
  final sourceId = lsl.bindings.lsl_get_source_id(nativeInfo);

  // Generated by LSL
  final version = lsl.bindings.lsl_get_version(nativeInfo);
  final createdAt = lsl.bindings.lsl_get_created_at(nativeInfo);
  final uid = lsl.bindings.lsl_get_uid(nativeInfo);
  final sessionId = lsl.bindings.lsl_get_session_id(nativeInfo);
  final hostname = lsl.bindings.lsl_get_hostname(nativeInfo);

  final streamInfo = getStreamInfoFromChannelFormat(
      nativeChannelFormat,
      name.cast<Utf8>().toDartString(),
      type.cast<Utf8>().toDartString(),
      channelCount,
      nominalSrate,
      sourceId.cast<Utf8>().toDartString());

  streamInfo.version = version;
  streamInfo.createdAt = createdAt;
  streamInfo.uid = uid.cast<Utf8>().toDartString();
  streamInfo.sessionId = sessionId.cast<Utf8>().toDartString();
  streamInfo.hostname = hostname.cast<Utf8>().toDartString();

  return streamInfo;
}
