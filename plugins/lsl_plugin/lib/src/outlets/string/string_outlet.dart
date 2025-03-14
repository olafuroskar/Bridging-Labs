part of '../../../lsl_plugin.dart';

class StringOutlet implements OutletRename<String> {
  late final SampleStrategy<String> _sampleStrategy;
  late final lsl_outlet _outlet;
  bool _isDestroyed = false;

  /// {@macro bindings}
  static LslInterface _lsl = Lsl();
  static MulticastLock _multicastLock = MulticastLock();

  /// {@macro set_bindings}
  static void setBindings(LslInterface lsl) {
    _lsl = lsl;
  }

  static void setMulticastLock(MulticastLock multicastLock) {
    _multicastLock = multicastLock;
  }

  /// {@macro outlet}
  StringOutlet(StreamInfo streamInfo,
      [int chunkSize = 0, int maxBuffered = 360]) {
    // Required on Android, TODO: Explain more...
    _multicastLock.acquire();

    _outlet = _lsl.bindings
        .lsl_create_outlet(streamInfo.handle(), chunkSize, maxBuffered);

    _sampleStrategy = StringSampleStrategyFactory.sampleStrategyFor(
        _outlet, streamInfo.getChannelFormat(), _lsl);
  }

  @override
  Result<Unit> destroy() {
    try {
      _lsl.bindings.lsl_destroy_outlet(_outlet);
      _multicastLock.release();
      _isDestroyed = true;
      return Result.ok(unit);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  @override
  bool get isDestroyed => _isDestroyed;

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      // Do nothing if sample does not contain any values
      return Result.ok(unit);
    }

    try {
      return _sampleStrategy.pushSample(sample);
    } on Exception catch (e) {
      return Result.error(e);
    } on TypeError catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
