part of '../../../lsl_plugin.dart';

class StringOutlet implements Outlet<String> {
  late final SampleStrategy<String> _sampleStrategy;
  late final lsl_outlet _outlet;

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
  StringOutlet(StreamInfo<StringChannelFormat> streamInfo,
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
    return destroyOutlet(_lsl, _outlet, _multicastLock);
  }

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    return _sampleStrategy.pushSample(sample);
  }
}
