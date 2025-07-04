part of '../../lsl_flutter.dart';

/// Domain class for an inlet
class Inlet<S> {
  /// a resolved stream info object.
  StreamInfo<S> streamInfo;

  /// Optionally the maximum amount of data to buffer (in seconds if there is a nominal
  /// sampling rate, otherwise x100 in samples). Recording applications want to use a fairly
  /// large buffer size here, while real-time applications would only buffer as much as
  /// they need to perform their next calculation.
  int maxBufLen;

  /// Optionally the maximum size, in samples, at which chunks are transmitted
  /// (the default corresponds to the chunk sizes used by the sender).
  /// Recording applications can use a generous size here (leaving it to the network how
  /// to pack things), while real-time applications may want a finer (perhaps 1-sample) granularity.
  /// If left unspecified (=0), the sender determines the chunk granularity.
  int maxChunkLen;

  /// Try to silently recover lost streams that are recoverable (=those that that have a
  /// source_id set).
  bool recover;

  /// Creates an instance of [Inlet]
  Inlet(this.streamInfo,
      [this.maxBufLen = 360, this.maxChunkLen = 0, this.recover = true]);
}
