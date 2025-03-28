part of '../../lsl_plugin.dart';

class Inlet<S> {
  StreamInfo<S> streamInfo;
  int maxBufLen;
  int maxChunkLen;
  bool recover;

  /// Creates a inlet domain object
  ///
  /// [streamInfo] a resolved stream info object.
  /// [maxBufLen] Optionally the maximum amount of data to buffer (in seconds if there is a nominal
  /// sampling rate, otherwise x100 in samples). Recording applications want to use a fairly
  /// large buffer size here, while real-time applications would only buffer as much as
  /// they need to perform their next calculation.
  /// [maxChunkLen] Optionally the maximum size, in samples, at which chunks are transmitted
  /// (the default corresponds to the chunk sizes used by the sender).
  /// Recording applications can use a generous size here (leaving it to the network how
  /// to pack things), while real-time applications may want a finer (perhaps 1-sample) granularity.
  /// If left unspecified (=0), the sender determines the chunk granularity.
  Inlet(this.streamInfo,
      [this.maxBufLen = 360, this.maxChunkLen = 0, this.recover = true]);
}
