part of '../../../lsl_plugin.dart';

class DoubleOutletBuilder implements OutletBuilder<double> {
  int _channelCount = 8;
  double _nominalSRate = 100;
  int _chunkSize = 0;
  int _maxBuffered = 360;
  DoubleChannelFormat channelFormat = Float32ChannelFormat();
  String _name = "";
  String _sourceId = "";
  String _type = "";

  DoubleOutletBuilder();

  @override
  String get name => _name;

  @override
  set name(String value) {
    _name = value;
  }

  @override
  String get sourceId => _sourceId;

  @override
  set sourceId(String value) {
    _sourceId = value;
  }

  @override
  String get type => _type;

  @override
  set type(String value) {
    _type = value;
  }

  @override
  int get channelCount => _channelCount;

  @override
  set channelCount(int value) {
    _channelCount = value;
  }

  @override
  double get nominalSRate => _nominalSRate;

  @override
  set nominalSRate(double value) {
    _nominalSRate = value;
  }

  @override
  int get chunkSize => _chunkSize;

  @override
  set chunkSize(int value) {
    _chunkSize = value;
  }

  @override
  int get maxBuffered => _maxBuffered;

  @override
  set maxBuffered(int value) {
    _maxBuffered = value;
  }

  @override
  Result<Outlet<double>> build() {
    try {
      final streamInfo = StreamInfo(
          _name, _type, channelFormat, _channelCount, _nominalSRate, _sourceId);

      final outlet = DoubleOutlet(streamInfo, chunkSize, maxBuffered);

      return Result.ok(outlet);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
