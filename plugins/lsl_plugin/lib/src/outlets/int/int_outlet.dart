part of '../../../lsl_plugin.dart';

class IntOutlet implements Outlet<int> {
  late final SampleStrategy<int> _sampleStrategy;
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

  /// {@template outlet}
  /// Establish a new stream outlet. This makes the stream discoverable.
  ///
  /// * [streamInfo] The stream information to use for creating this stream.
  /// Stays constant over the lifetime of the outlet.
  /// the outlet makes a copy of the streaminfo object upon construction (so the old info should
  /// still be destroyed. [StreamInfo.destroy])
  /// * [chunkSize] Optionally the desired chunk granularity (in samples) for transmission.
  /// If specified as 0, each push operation yields one chunk.
  /// Stream recipients can have this setting bypassed.
  /// * [maxBuffered] Optionally the maximum amount of data to buffer (in seconds if there is a
  /// nominal sampling rate, otherwise x100 in samples). A good default is 360, which corresponds to 6
  /// minutes of data. Note that, for high-bandwidth data you will almost certainly want to use a lower
  /// value here to avoid running out of RAM.
  /// {@endtemplate}
  IntOutlet(StreamInfo<IntChannelFormat> streamInfo,
      [int chunkSize = 0, int maxBuffered = 360]) {
    // Required on Android, TODO: Explain more...
    _multicastLock.acquire();

    _outlet = _lsl.bindings
        .lsl_create_outlet(streamInfo.handle(), chunkSize, maxBuffered);

    _sampleStrategy = IntSampleStrategyFactory.sampleStrategyFor(
        _outlet, streamInfo.getChannelFormat(), _lsl);
  }

  @override
  Result<Unit> destroy() {
    return destroyOutlet(_lsl, _outlet, _multicastLock);
  }

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    return _sampleStrategy.pushSample(sample);
  }
}
