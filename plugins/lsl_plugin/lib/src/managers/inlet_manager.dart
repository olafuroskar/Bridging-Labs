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
  Future<Sample<S>?> pullSample([double timeout = 0]) async {
    return await _inletAdapter.pullSample();
  }

  /// {@macro pull_chunk}
  Future<Chunk<S>?> pullChunk([double timeout = 0]) {
    return _inletAdapter.pullChunk(timeout);
  }

  /// {@macro get_inlet_stream_info}
  StreamInfo getStreamInfo() {
    return _inletAdapter.getStreamInfo();
  }

  /// {@macro time_correction}
  Future<double> timeCorrection([double timeout = double.infinity]) {
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

  Stream<Sample<S>> startSampleStream() async* {
    if (isClosed) return;
    final nominalSRate = getStreamInfo().nominalSRate.toInt();

    while (true) {
      await Future.delayed(Duration(seconds: nominalSRate));

      final sample = await pullSample();
      if (sample != null) {
        yield sample;
      }
      if (isClosed) break;
    }
  }

  Stream<Chunk<S>> startChunkStream() async* {
    if (isClosed) return;
    final nominalSRate = getStreamInfo().nominalSRate.toInt();

    while (true) {
      await Future.delayed(Duration(seconds: nominalSRate));

      final chunk = await pullChunk();
      if (chunk != null) {
        yield chunk;
      }
      if (isClosed) break;
    }
  }
}
