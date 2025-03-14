part of '../../../lsl_plugin.dart';

class IntOutletBuilder implements OutletBuilder<int> {
  int _channelCount = 8;
  double _nominalSRate = 100;
  int _chunkSize = 0;
  int _maxBuffered = 360;
  IntChannelFormat channelFormat = Int32ChannelFormat();
  String _name = "";
  String _sourceId = "";
  String _type = "";

  IntOutletBuilder();

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
  Result<Outlet<int>> build() {
    try {
      StreamInfo streamInfo = StreamInfo(
          _name, _type, _channelCount, _nominalSRate, channelFormat, _sourceId);

      final outlet = IntOutlet(streamInfo, chunkSize, maxBuffered);

      return Result.ok(outlet);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
