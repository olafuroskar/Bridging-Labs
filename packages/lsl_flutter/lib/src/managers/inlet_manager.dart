part of 'managers.dart';

/// An object used to manage inlets and its associated functions.
///
/// Only has a private constructor, used by [StreamManager].
///
/// ```dart
/// final InletManager<dynamic> inlet = streamManager.createInlet(handles[0]);
///
/// final samplingRate = inlet.getStreamInfo().nominalSRate;
///
/// final chunkStream = inlet.startChunkStream(samplingRate);
///
/// chunkStream.listen((Chunk<dynamic> chunk) {
///   print("Chunk recieved with ${chunk.length} samples");
/// });
///
/// inlet.closeStream();
/// ```
class InletManager<S> {
  late final InletAdapter<S> _inletAdapter;
  final UtilsAdapter _utilsAdapter = UtilsAdapter();
  bool _isStreamingSamples = false;
  bool _isStreamingChunks = false;
  bool _isStreamingTimeCorrections = false;

  InletManager._(this._inletAdapter);

  /// {@macro open_stream}
  void openStream([double timeout = double.infinity]) {
    _inletAdapter.openStream();
  }

  /// {@macro close_stream}
  void closeStream() {
    _inletAdapter.closeStream();
  }

  /// {@macro pull_sample}
  Sample<S>? pullSample([double timeout = 0]) {
    return _inletAdapter.pullSample();
  }

  /// {@macro pull_chunk}
  Chunk<S>? pullChunk([double timeout = 0]) {
    return _inletAdapter.pullChunk(timeout);
  }

  /// {@macro get_inlet_stream_info}
  StreamInfo getStreamInfo() {
    return _inletAdapter.getStreamInfo();
  }

  /// {@macro time_correction}
  double timeCorrection([double timeout = double.infinity]) {
    return _inletAdapter.timeCorrection(timeout);
  }

  /// {@macro samples_available}
  int samplesAvailable() {
    return _inletAdapter.samplesAvailable();
  }

  /// {@macro was_clock_reset}
  bool wasClockReset() {
    return _inletAdapter.wasClockReset();
  }

  /// Sets the post processing option ([ProcessingOptions]) of the inlet
  ErrorCode setPostProcessing(List<ProcessingOptions> flags) {
    return _inletAdapter.setPostProcessing(flags);
  }

  Duration _delay(double nominalSRate) {
    if ((1000 / nominalSRate).isInfinite) return Duration(seconds: 1);
    return Duration(milliseconds: (1000 / nominalSRate).toInt());
  }

  /// Starts a stream that pulls samples from the inlet with the [samplingRate]
  Stream<Sample<S>> startSampleStream(double? samplingRate) async* {
    // Early return if manager is already streaming.
    if (_isStreamingSamples) return;
    _isStreamingSamples = true;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = _delay(samplingRate ?? nominalSRate);

    while (true) {
      await Future.delayed(delay);

      if (!_isStreamingSamples) break;

      try {
        final sample = pullSample();
        if (sample != null && sample.$1.isNotEmpty) {
          yield sample;
        }
      } catch (e) {
        break;
      }
    }
  }

  /// Stops an active sample stream, that has been started with [startSampleStream]
  void stopSampleStream() {
    _isStreamingSamples = false;
  }

  /// Starts a stream that pulls chunks from the inlet with the [samplingRate]
  Stream<Chunk<S>> startChunkStream(double? samplingRate) async* {
    // Early return if manager is already streaming.
    if (_isStreamingChunks) return;
    _isStreamingChunks = true;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = _delay(samplingRate ?? nominalSRate);

    while (true) {
      await Future.delayed(delay);

      if (!_isStreamingChunks) break;

      try {
        final chunk = pullChunk();
        if (chunk != null && chunk.isNotEmpty) {
          yield chunk;
        }
      } catch (e) {
        break;
      }
    }
  }

  /// Stops an active chunk stream, that has been started with [startChunkStream]
  void stopChunkStream() {
    _isStreamingChunks = false;
  }

  /// Starts a stream that gets the [timeCorrection] offset of the inlet in intervals of duration [interval]
  Stream<TimeOffset> startTimeCorrectionStream(
      {Duration interval = const Duration(seconds: 5),
      double timeout = double.infinity}) async* {
    if (_isStreamingTimeCorrections) return;
    _isStreamingTimeCorrections = true;

    while (true) {
      await Future.delayed(interval);

      if (!_isStreamingTimeCorrections) break;

      final offset = timeCorrection(timeout);
      final now = _utilsAdapter.localClock();
      yield (now, offset);
    }
  }

  /// Stops an active time correction stream, that has been started with [startTimeCorrectionStream]
  void stopTimeCorrectionStream() {
    _isStreamingTimeCorrections = false;
  }
}
