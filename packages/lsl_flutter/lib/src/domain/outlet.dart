part of '../../lsl_flutter.dart';

/// Domain class for an outlet
class Outlet<S> {
  /// The stream information to use for creating this stream.
  /// Stays constant over the lifetime of the outlet.
  StreamInfo<S> streamInfo;

  /// Optionally the desired chunk granularity (in samples) for transmission.
  /// If specified as 0, each push operation yields one chunk.
  /// Stream recipients can have this setting bypassed.
  int chunkSize;

  /// Optionally the maximum amount of data to buffer (in seconds if there is a
  /// nominal  sampling rate, otherwise x100 in samples). A good default is 360, which corresponds to 6
  /// minutes of data. Note that, for high-bandwidth data you will almost certainly want to use a lower
  /// value here to avoid  running out of RAM.
  int maxBuffered;

  /// Creates an instance of [Outlet]
  Outlet(this.streamInfo, [this.chunkSize = 0, this.maxBuffered = 360]);
}
