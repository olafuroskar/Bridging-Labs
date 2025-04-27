import 'dart:io';

import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:sensors/main.dart';
import 'package:sensors/src/models/outlet_config_dto.dart';
import 'package:sensors_plus/sensors_plus.dart';

OutletConfigDto polarConfig(String name, String type) {
  return OutletConfigDto(
    name: name,
    channelFormat: Int64ChannelFormat(),
    type: type,
    streamType: StreamType.polar,
    channelCount: 4,
    useLslTimestamps: false,
    nominalSRate: 135,
    sourceId: "Polar $name",
    mode: OffsetMode.applyFirstToSamples,
  );
}

OutletConfigDto museConfig(String name, String type) {
  return OutletConfigDto(
    name: name,
    channelFormat: Int64ChannelFormat(),
    type: type,
    streamType: StreamType.muse,
    channelCount: 3,
    useLslTimestamps: false,
    nominalSRate: 64,
    sourceId: "Muse $name",
  );
}

OutletConfigDto sensorsConfig(String name, String type, StreamType streamType) {
  return OutletConfigDto(
    name: name,
    channelFormat: Double64ChannelFormat(),
    type: type,
    streamType: streamType,
    channelCount: 3,
    useLslTimestamps: false,
    nominalSRate: intervalToFrequency(SensorInterval.normalInterval),
    sourceId: name + Platform.operatingSystem,
  );
}

OutletConfigDto getConfig(String name, String type, StreamType streamType) {
  switch (streamType) {
    case StreamType.gyroscope:
      return sensorsConfig(name, type, StreamType.gyroscope);
    case StreamType.accelerometer:
      return sensorsConfig(name, type, StreamType.accelerometer);
    case StreamType.muse:
      return museConfig(name, type);
    case StreamType.polar:
      return polarConfig(name, type);
  }
}
