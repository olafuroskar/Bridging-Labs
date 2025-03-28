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
  Result<Unit> closeStream() {
    final result = _inletAdapter.closeStream();
    switch (result) {
      case Ok():
        isClosed = true;
      default:
    }
    return result;
  }

  /// {@macro pull_sample}
  Future<(List<S> sample, double timestamp)?> pullSample(
      [double timeout = 0]) async {
    return await _inletAdapter.pullSample();
  }

  /// {@macro pull_chunk}
  Future<List<(List<S> sample, double timestamp)>?> pullChunk(
      [double timeout = 0]) {
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
  Result<int> samplesAvailable() {
    return _inletAdapter.samplesAvailable();
  }

  /// {@macro was_clock_reset}
  Result<bool> wasClockReset() {
    return _inletAdapter.wasClockReset();
  }

  Stream<(List<S>, double)> startSampleStream() async* {
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

  Stream<List<(List<S>, double)>> startChunkStream() async* {
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
