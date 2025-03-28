part of 'managers.dart';

class StreamManager {
  final StreamAdapter _streamAdapter = AsyncStreamAdapter();

  StreamManager();

  Future<void> resolveStreams(double waitTime) {
    return _streamAdapter.resolveStreams(waitTime);
  }

  List<ResolvedStreamHandle<int>> getIntStreamHandles() {
    return _streamAdapter.getIntStreamHandles();
  }

  List<ResolvedStreamHandle<double>> getDoubleStreamHandles() {
    return _streamAdapter.getDoubleStreamHandles();
  }

  List<ResolvedStreamHandle<String>> getStringStreamHandles() {
    return _streamAdapter.getStringStreamHandles();
  }

  InletManager<S> createInlet<S>(ResolvedStreamHandle<S> handle) {
    final inletAdapter = _streamAdapter.createInlet<S>(handle);
    final inletManager = InletManager<S>._(inletAdapter);

    return inletManager;
  }
}
