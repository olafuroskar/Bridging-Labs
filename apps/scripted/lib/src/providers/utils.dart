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
    channelFormat: Double64ChannelFormat(),
    type: type,
    streamType: streamType,
    channelCount: 1,
    nominalSRate: 100,
    sourceId: name,
  );
}

OutletConfigDto markerConfig(String name, String type, StreamType streamType,
    [int? channelCount]) {
  return OutletConfigDto(
    name: name,
    channelFormat: CftStringChannelFormat(),
    type: type,
    streamType: streamType,
    channelCount: channelCount ?? 1,
    nominalSRate: 0,
    sourceId: name,
  );
}

OutletConfigDto getConfig(String name, StreamType streamType,
    {int? channelCount}) {
  switch (streamType) {
    case StreamType.random:
      return randomConfig(name, "White noise", StreamType.random);
    case StreamType.sine:
      return sineConfig(name, "Sine wave", StreamType.sine);
    case StreamType.marker:
      return markerConfig(name, "Marker", StreamType.marker, channelCount);
  }
}

final timeToleranceInSeconds = Duration(milliseconds: 1000).inSeconds;

// Find matching samples within tolerance
(Sample<double>? sample, int index) findMathcingSample(
  List<Sample<double>> buffer,
  double targetTimestamp,
) {
  Sample<double>? closest;
  var minDiff = double.infinity;
  int index = -1;
  int i = -1;

  for (final (sample, timestamp) in buffer) {
    i++;
    final diff = (timestamp - targetTimestamp).abs();
    if (diff < timeToleranceInSeconds && diff < minDiff) {
      closest = (sample, timestamp);
      minDiff = diff;
      index = i;
    }
  }
  return (closest, index);
}
