part of 'managers.dart';

/// How should offsets between the devices current time and provided timestamps be handled in the outlet manager.
enum OffsetMode {
  /// Don't handle time offsets
  none("none"),

  /// Records the estimated time offset periodically.
  record("record"),

  /// Applies the first recorded offset and ignores subsequent offsets.
  ///
  /// This option is only meant to offset the streamed samples once. Changing the offsets
  /// during the lifetime of the outlet may skew the data, as the data may also be post-
  /// processed when it reaches an inlet.
  applyFirstToSamples("apply first to samples");

  /// The string value of the offset mode
  final String value;

  const OffsetMode(this.value);
}

/// An outlet configuration object
///
/// Encapsulates the configuration parameters of an [OutletManager]
class OutletConfig {
  /// [chunkSize] The desired chunk granularity (in samples) for transmission.
  /// If specified as 0, each push operation yields one chunk.
  final int chunkSize;

  /// [maxBuffered] Optionally the maximum amount of data to buffer (in seconds if there is a
  /// nominal sampling rate, otherwise x100 in samples). A good default is 360, which corresponds to 6
  /// minutes of data. Note that, for high-bandwidth data you will almost certainly want to use a lower
  /// value here to avoid  running out of RAM.
  final int maxBuffered;

  /// [mode] The mode to use for processing host/device time offsets.
  final OffsetMode mode;

  /// [offsetCalculationInterval] - Interval (in seconds) for computing new offsets.
  final double offsetCalculationInterval;

  /// Creates an [OutletConfig] instance
  const OutletConfig(this.chunkSize, this.maxBuffered,
      [this.mode = OffsetMode.none, this.offsetCalculationInterval = 5.0]);

  /// Creates an [OutletConfig] instance given a [mode] and a [offsetCalculationInterval].
  OutletConfig.fromOffsetConfig(
      {OffsetMode mode = OffsetMode.none, double offsetCalculationInterval = 5})
      : this(0, 360, mode, offsetCalculationInterval);
}

/// A service for interacting with a single outlet.
///
/// An instance can be reused for multiple outlets (after being destroyed),
/// but creating new instances instead is encouraged for clarity.
///
/// ```dart
/// final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
///     "Polar 123", "PPG", Double64ChannelFormat(),
///     channelCount: 3, nominalSRate: 135, sourceId: "Polar 123");
///
/// final StreamInfo<double> streamInfo =
///     StreamInfoFactory.createDoubleStreamInfo(
///         "Polar Verity Sense", "PPG", Double64ChannelFormat(),
///         channelCount: 3, nominalSRate: 135, sourceId: "Polar Verity Sense");
///
/// final OutletConfig config =
///     OutletConfig.fromOffsetConfig(mode: OffsetMode.applyFirstToSamples);
///
/// final OutletManager<double> outlet = OutletManager(streamInfo, config);
///
/// final List<double> sample = [1.2, 2.0, 3.4];
/// outlet.pushSample(sample, DartTimestamp(DateTime.now()));
///
/// outlet.destroy();
/// ```
class OutletManager<S> {
  late final StreamInfo<S> _streamInfo;
  late final OutletAdapter<S> _outletAdapter;
  late final OutletConfig _config;

  double _lastBase = 0;
  double? _lastOffset;
  final List<double> _offsets = [];
  final List<Timestamp> _offsetRecordingTimestamps = [];

  /// Creates a new [OutletManager].
  ///
  /// [streamInfo] Metadata on the stream to be created
  /// [config] Configuration parameters specified in [OutletConfig]
  OutletManager(StreamInfo<S> streamInfo, [OutletConfig? config]) {
    _streamInfo = streamInfo;
    _config = config ?? OutletConfig(0, 360, OffsetMode.none, 5);

    final outlet =
        Outlet<S>(_streamInfo, _config.chunkSize, _config.maxBuffered);

    if (S == int) {
      _outletAdapter = OutletAdapterFactory.createIntAdapterFromChannelFormat(
          outlet as Outlet<int>) as OutletAdapter<S>;
    } else if (S == double) {
      _outletAdapter =
          OutletAdapterFactory.createDoubleAdapterFromChannelFormat(
              outlet as Outlet<double>) as OutletAdapter<S>;
    } else if (S == String) {
      _outletAdapter =
          OutletAdapterFactory.createStringAdapterFromChannelFormat(
              outlet as Outlet<String>) as OutletAdapter<S>;
    } else {
      throw Exception("Unsupported type $S");
    }
  }

  /// Pushes a single sample to the outlet.
  void pushSample(List<S> sample,
      [Timestamp? timestamp, bool pushthrough = true]) {
    _updateOffset(timestamp);

    _outletAdapter.pushSample(
      sample,
      _config.mode != OffsetMode.applyFirstToSamples
          ? timestamp
          : _applyOffsetToOptionalTimestamp(timestamp),
      pushthrough,
    );
  }

  /// Pushes a chunk of samples to the outlet.
  void pushChunk(List<List<S>> chunk,
      [Timestamp? timestamp, bool pushthrough = true]) {
    _updateOffset(timestamp);

    _outletAdapter.pushChunk(
      chunk,
      _config.mode != OffsetMode.applyFirstToSamples
          ? timestamp
          : _applyOffsetToOptionalTimestamp(timestamp),
      pushthrough,
    );
  }

  /// Pushes a chunk of samples with explicit timestamps.
  void pushChunkWithTimestamps(List<List<S>> chunk, List<Timestamp> timestamps,
      [bool pushthrough = true]) {
    // The last sample of a chunk should be the latest sample and therefore the closest in time
    // to the local clock of the streaming device.
    _updateOffset(timestamps.last);

    _outletAdapter.pushChunkWithTimestamps(
      chunk,
      _config.mode != OffsetMode.applyFirstToSamples
          ? timestamps
          : timestamps.map(_applyOffsetToTimestamp).toList(),
      pushthrough,
    );
  }

  /// Destroys the outlet.
  void destroy() => _outletAdapter.destroy();

  /// Returns the [StreamInfo] for the outlet.
  StreamInfo getStreamInfo() => _outletAdapter.getStreamInfo();

  /// Returns whether there are consumers connected to this outlet.
  bool haveConsumers() => _outletAdapter.haveConsumers();

  /// Waits for consumers to connect, with a timeout.
  bool waitForConsumers(double timeout) =>
      _outletAdapter.waitForConsumers(timeout);

  /// Returns the list of recorded time offsets between host and device clocks.
  List<(double, Timestamp)> get offsets {
    final List<(double, Timestamp)> offsets = [];
    for (var i = 0; i < _offsets.length; i++) {
      offsets.add((_offsets[i], _offsetRecordingTimestamps[i]));
    }
    return offsets;
  }

  void _updateOffset(Timestamp? timestamp) {
    if (_config.mode == OffsetMode.none) return;

    /// If first offset is only to be applied, exit if it has been stored once already.
    if (_lastOffset != null && _config.mode == OffsetMode.applyFirstToSamples) {
      return;
    }

    if (timestamp == null) {
      throw Exception(
        "Offsets can only be used when timestamps are provided explicitly.",
      );
    }

    final base = DartTimestamp(DateTime.now()).toLslTime();
    if (base - _lastBase < _config.offsetCalculationInterval) return;

    final offset = base - timestamp.toLslTime();
    _lastOffset = offset;
    _offsets.add(offset);
    _offsetRecordingTimestamps.add(DartTimestamp(DateTime.now()));
    _lastBase = base;
  }

  Timestamp? _applyOffsetToOptionalTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return null;
    return _applyOffsetToTimestamp(timestamp);
  }

  Timestamp _applyOffsetToTimestamp(Timestamp timestamp) {
    return LslTimestamp(timestamp.toLslTime() + (_lastOffset ?? 0));
  }
}
