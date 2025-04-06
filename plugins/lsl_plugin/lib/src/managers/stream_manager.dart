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

  List<ResolvedStreamHandle<Object?>> getStreamHandles() {
    return getIntStreamHandles()
            .map<ResolvedStreamHandle<Object?>>((item) => item)
            .toList() +
        getDoubleStreamHandles()
            .map<ResolvedStreamHandle<Object?>>((item) => item)
            .toList() +
        getStringStreamHandles()
            .map<ResolvedStreamHandle<Object?>>((item) => item)
            .toList();
  }

  ResolvedStreamHandle<Object?>? getStreamHandle(String streamId) {
    final handles = getStreamHandles();
    if (handles.isEmpty) return null;

    final index = handles.indexWhere((handle) => handle.id == streamId);
    if (index == -1) return null;

    return handles[index];
  }

  InletManager<S> createInlet<S>(ResolvedStreamHandle<S> handle) {
    final inletAdapter = _streamAdapter.createInlet<S>(handle);
    final inletManager = InletManager<S>._(inletAdapter);

    return inletManager;
  }

  InletManager<Object?>? createInletFromId(String streamId) {
    final handle = getStreamHandle(streamId);
    if (handle != null) return null;

    if (handle is ResolvedStreamHandle<int>) {
      return createInlet<int>(handle);
    } else if (handle is ResolvedStreamHandle<double>) {
      return createInlet<double>(handle);
    } else if (handle is ResolvedStreamHandle<String>) {
      return createInlet<String>(handle);
    }
    return null;
  }

  void destroyStreams() {
    return _streamAdapter.destroyStreams();
  }
}
