part of 'managers.dart';

class StreamManager {
  final StreamAdapter _streamAdapter = StreamAdapter();

  StreamManager();

  /// {@macro resolve_all}
  void resolveStreams(double timeout) {
    return _streamAdapter.resolveAllStreams(timeout);
  }

  /// {@macro resolve_prop}
  void resolveStreamsByPred(double timeout, String pred, int minimum) {
    return _streamAdapter.resolveStreamsByPred(timeout, pred, minimum);
  }

  /// {@macro resolve_pred}
  void resolveStreamsByProp(
      double timeout, String prop, String value, int minimum) {
    return _streamAdapter.resolveStreamsByProp(timeout, prop, value, minimum);
  }

  /// {@macro get_stream_handles}
  List<ResolvedStreamHandle> getStreamHandles() {
    return _streamAdapter.getStreamHandles();
  }

  /// Gets a resolved stream handle from a stream id
  ///
  /// [streamId] Id of a resolved stream
  ResolvedStreamHandle? getStreamHandle(String streamId) {
    final handles = getStreamHandles();
    if (handles.isEmpty) return null;

    final index = handles.indexWhere((handle) => handle.id == streamId);
    if (index == -1) return null;

    return handles[index];
  }

  /// Creates an inlet from a given stream handle
  ///
  /// [handle] A resolved stream handle
  InletManager<S> createInlet<S>(ResolvedStreamHandle handle) {
    final inletAdapter = _streamAdapter.createInlet<S>(handle);
    final inletManager = InletManager<S>._(inletAdapter);

    return inletManager;
  }

  /// Creates an inlet from a stream id
  ///
  /// [streamId] Id of a resolved stream
  InletManager<Object?>? createInletFromId(String streamId) {
    try {
      final handle = getStreamHandle(streamId);

      if (handle == null) return null;

      if (handle.info is StreamInfo<int>) {
        return createInlet<int>(handle);
      } else if (handle.info is StreamInfo<double>) {
        return createInlet<double>(handle);
      } else if (handle.info is StreamInfo<String>) {
        return createInlet<String>(handle);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// {@macro destroy_streams}
  void destroyStreams() {
    return _streamAdapter.destroyStreams();
  }
}
