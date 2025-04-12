part of 'managers.dart';

class InletManager<S> {
  late final InletAdapter<S> _inletAdapter;
  bool isClosed = true;

  InletManager._(this._inletAdapter);

  /// {@macro open_stream}
  Future<void> openStream([double timeout = double.infinity]) async {
    _inletAdapter.openStream();
    isClosed = false;
  }

  /// {@macro close_stream}
  void closeStream() {
    isClosed = true;
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

  Stream<Sample<S>> startSampleStream() async* {
    if (isClosed) return;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = Duration(milliseconds: (1000 / nominalSRate).toInt());

    while (true) {
      await Future.delayed(delay);

      final sample = pullSample();
      if (sample != null && sample.$1.isNotEmpty) {
        yield sample;
      }
      if (isClosed) break;
    }
  }

  Stream<Chunk<S>> startChunkStream() async* {
    if (isClosed) return;
    final nominalSRate = getStreamInfo().nominalSRate;
    final delay = Duration(milliseconds: (1000 / nominalSRate).toInt());

    while (true) {
      await Future.delayed(delay);

      final chunk = pullChunk();
      if (chunk != null && chunk.isNotEmpty) {
        yield chunk;
      }
      if (isClosed) break;
    }
  }
}
