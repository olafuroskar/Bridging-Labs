part of 'managers.dart';

class InletManager<S> {
  late final InletAdapter<S> _inletAdapter;
  final UtilsAdapter _utilsAdapter = UtilsAdapter();
  bool _isStreaming = false;

  InletManager._(this._inletAdapter);

  /// {@macro open_stream}
  Future<void> openStream([double timeout = double.infinity]) async {
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

  ErrorCode setPostProcessing(List<ProcessingOptions> flags) {
    return _inletAdapter.setPostProcessing(flags);
  }

  Duration _delay(double nominalSRate) {
    if ((1000 / nominalSRate).isInfinite) return Duration(seconds: 1);
    return Duration(milliseconds: (1000 / nominalSRate).toInt());
  }

  stopStream() {
    _isStreaming = false;
  }

  Stream<Sample<S>> startSampleStream(double? samplingRate) async* {
    // Early return if manager is already streaming.
    if (_isStreaming) return;
    _isStreaming = true;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = _delay(samplingRate ?? nominalSRate);

    while (true) {
      await Future.delayed(delay);

      if (!_isStreaming) break;

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

  Stream<Chunk<S>> startChunkStream(double? samplingRate) async* {
    // Early return if manager is already streaming.
    if (_isStreaming) return;
    _isStreaming = true;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = _delay(samplingRate ?? nominalSRate);

    while (true) {
      await Future.delayed(delay);

      if (!_isStreaming) break;

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

  Stream<TimeOffset> startTimeCorrectionStream(
      {Duration interval = const Duration(seconds: 5),
      double timeout = double.infinity}) async* {
    if (_isStreaming) return;
    _isStreaming = true;

    while (true) {
      await Future.delayed(interval);

      if (!_isStreaming) break;

      final offset = timeCorrection(timeout);
      final now = _utilsAdapter.localClock();
      yield (now, offset);
    }
  }
}
