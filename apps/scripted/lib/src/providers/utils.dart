import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:scripted/main.dart';
import 'package:scripted/src/models/outlet_config_dto.dart';

OutletConfigDto randomConfig(String name, String type, StreamType streamType) {
  return OutletConfigDto(
    name: name,
    channelFormat: Double64ChannelFormat(),
    type: type,
    streamType: streamType,
    channelCount: 3,
    nominalSRate: 100,
    sourceId: name,
  );
}

OutletConfigDto sineConfig(String name, String type, StreamType streamType) {
  return OutletConfigDto(
    name: name,
    channelFormat: CftStringChannelFormat(),
    type: type,
    streamType: streamType,
    channelCount: 1,
    nominalSRate: 100,
    sourceId: name,
  );
}

OutletConfigDto getConfig(String name, StreamType streamType) {
  switch (streamType) {
    case StreamType.random:
      return randomConfig(name, "White noise", StreamType.random);
    case StreamType.sine:
      return sineConfig(name, "Sine wave", StreamType.sine);
  }
}
