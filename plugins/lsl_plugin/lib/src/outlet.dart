part of '../lsl_plugin.dart';

class Outlet<T> {
  late final lsl_outlet _outlet;
  late final SampleStrategy _sampleStrategy;
  bool _isDestroyed = false;

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
  Outlet(StreamInfo streamInfo, [int chunkSize = 0, int maxBuffered = 360]) {
    // Required on Android, TODO: Explain more...
    MulticastLock().acquire();

    _outlet =
        bindings.lsl_create_outlet(streamInfo.handle(), chunkSize, maxBuffered);

    _sampleStrategy = SampleStrategyFactory.sampleStrategyFor(
        _outlet, streamInfo.getChannelFormat());
  }

  /// Destroys the outlet.
  ///
  /// Should be called when the outlet is no longer in use.
  /// Consider also destroying the connected stream info.
  void destroy() {
    bindings.lsl_destroy_outlet(_outlet);
    MulticastLock().release();
    _isDestroyed = true;
  }

  /// Whether the outlet has been destroyed or not
  bool isDestroyed() {
    return _isDestroyed;
  }

  /// {@macro push_sample}
  Result<Unit> pushSample(List<T> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      // Do nothing if sample does not contain any values
      return Result.ok(unit);
    }

    return _sampleStrategy.pushSample(sample);
  }
}
