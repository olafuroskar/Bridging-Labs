part of 'managers.dart';

/// A service for interacting with a single outlet
///
/// An instance can be re-used for multiple outlets (after being destroyed of course), but
/// creaing new instances instead is incouraged for clarity.
class OutletManager<S> {
  late int _chunkSize;
  late int _maxBuffered;
  late StreamInfo<S> _streamInfo;

  late OutletAdapter<S> _outletAdapter;

  /// Whether device vs. host time offsets should be recorded
  late bool _recordOffsets;

  /// Whether offsets should be applied to timestamps when pushing
  late bool _applyOffsets;

  /// The interval in which offsets are calculated
  late double _offsetCalculationInterval;

  /// Keep track of the last base (host) timestamp
  double _lastBase = 0;

  /// Keep track of last offset to avoid lookup each time it's used
  double _lastOffset = 0;

  /// The recorder offsets between host and device
  final List<double> _offsets = [];

  /// {@macro create}
  /// [recordOffsets] Whether device vs. host time offsets should be recorded
  /// [applyOffsets] Whether offsets should be applied to timestamps when pushing
  /// [offsetCalculationInterval] The interval in which offsets are calculated
  OutletManager(StreamInfo<S> streamInfo,
      {int outletChunkSize = 0,
      int outletMaxBuffered = 360,
      bool recordOffsets = false,
      bool applyOffsets = false,
      double offsetCalculationInterval = 5.0}) {
    _streamInfo = streamInfo;
    _chunkSize = outletChunkSize;
    _maxBuffered = outletMaxBuffered;

    _recordOffsets = recordOffsets;
    _applyOffsets = applyOffsets;
    _offsetCalculationInterval = offsetCalculationInterval;

    final outlet = Outlet<S>(_streamInfo, _chunkSize, _maxBuffered);

    OutletAdapter<S>? outletAdapter;

    if (S == int) {
      /// Get the appropriate outlet adapter for the given integer channel format
      ///
      /// Here we have already established that S is in fact int
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<int>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createIntAdapterFromChannelFormat(
          outlet as Outlet<int>) as OutletAdapter<S>;
    } else if (S == double) {
      /// Get the appropriate outlet adapter for the given double channel format
      ///
      /// Here we have already established that S is in fact double
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<double>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createDoubleAdapterFromChannelFormat(
          outlet as Outlet<double>) as OutletAdapter<S>;
    } else if (S == String) {
      /// Get the appropriate outlet adapter for the given String channel format
      ///
      /// Here we have already established that S is in fact String
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<String>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createStringAdapterFromChannelFormat(
          outlet as Outlet<String>) as OutletAdapter<S>;
    } else {
      throw Exception("Unsupported type $S");
    }

    _outletAdapter = outletAdapter;
  }

  /// {@macro push_sample}
  void pushSample(List<S> sample,
      [Timestamp? timestamp, bool pushthrough = true]) {
    _updateOffset(timestamp);

    return _outletAdapter.pushSample(
        sample,
        !_applyOffsets ? timestamp : _applyOffsetToOptionalTimestamp(timestamp),
        pushthrough);
  }

  /// {@macro push_chunk}
  void pushChunk(List<List<S>> chunk,
      [Timestamp? timestamp, bool pushthrough = true]) {
    _updateOffset(timestamp);

    return _outletAdapter.pushChunk(
        chunk,
        !_applyOffsets ? timestamp : _applyOffsetToOptionalTimestamp(timestamp),
        pushthrough);
  }

  /// {@macro push_chunk_with_timestamps}
  void pushChunkWithTimestamps(List<List<S>> chunk, List<Timestamp> timestamps,
      [bool pushthrough = true]) {
    _updateOffset(timestamps.first);

    return _outletAdapter.pushChunkWithTimestamps(
        chunk,
        !_applyOffsets
            ? timestamps
            : timestamps.map(_applyOffsetToTimestamp).toList(),
        pushthrough);
  }

  /// {@macro destroy}
  void destroy() {
    return _outletAdapter.destroy();
  }

  /// {@macro get_stream_info}
  StreamInfo getStreamInfo() {
    return _outletAdapter.getStreamInfo();
  }

  /// {@macro have_consumers}
  bool haveConsumers() {
    return _outletAdapter.haveConsumers();
  }

  /// {@macro wait_for_consumers}
  bool waitForConsumers(double timeout) {
    return _outletAdapter.waitForConsumers(timeout);
  }

  /// Gets the estimated time offset between the clock of the intermediary device (the app) and the device providing timestamps.
  List<double> get offsets => _offsets;

  /// Update the
  void _updateOffset(Timestamp? timestamp) {
    if (!_recordOffsets && !_applyOffsets) return;

    if (timestamp == null) {
      throw Exception(
          "The record/apply offsets option can only be used when timestamps are provided explicitly");
    }

    final base = DartTimestamp(DateTime.now()).toLslTime();

    /// If unsufficient time has passed, exit early
    if (base - _lastBase < _offsetCalculationInterval) return;

    final t0 = timestamp.toLslTime();
    _lastOffset = t0 - base;

    offsets.add(_lastOffset);
    _lastBase = base;
  }

  /// Apply the last recorded offset to a timestamp
  Timestamp? _applyOffsetToOptionalTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return null;
    return _applyOffsetToTimestamp(timestamp);
  }

  /// Apply the last recorded offset to a timestamp
  Timestamp _applyOffsetToTimestamp(Timestamp timestamp) {
    return LslTimestamp(timestamp.toLslTime() + _lastOffset);
  }
}
