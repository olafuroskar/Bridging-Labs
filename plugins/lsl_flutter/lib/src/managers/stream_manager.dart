part of 'managers.dart';

class StreamManager {
  final StreamAdapter _streamAdapter = StreamAdapter();

  StreamManager();

  /// {@macro resolve_all}
  void resolveStreams(double waitTime) {
    return _streamAdapter.resolveAllStreams(waitTime);
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
  List<ResolvedStreamHandle<Object?>> getStreamHandles() {
    return _streamAdapter.getStreamHandles();
  }

  /// Gets a resolved stream handle from a stream id
  ///
  /// [streamId] Id of a resolved stream
  ResolvedStreamHandle<Object?>? getStreamHandle(String streamId) {
    final handles = getStreamHandles();
    if (handles.isEmpty) return null;

    final index = handles.indexWhere((handle) => handle.id == streamId);
    if (index == -1) return null;

    return handles[index];
  }

  /// Creates an inlet from a given stream handle
  ///
  /// [handle] A resolved stream handle
  InletManager<S> createInlet<S>(ResolvedStreamHandle<S> handle) {
    final inletAdapter = _streamAdapter.createInlet<S>(handle);
    final inletManager = InletManager<S>._(inletAdapter);

    return inletManager;
  }

  /// Creates an inlet from a stream id
  ///
  /// [streamId] Id of a resolved stream
  InletManager<Object?>? createInletFromId(String streamId) {
    final handle = getStreamHandle(streamId);

    if (handle is ResolvedStreamHandle<int>) {
      return createInlet<int>(handle);
    } else if (handle is ResolvedStreamHandle<double>) {
      return createInlet<double>(handle);
    } else if (handle is ResolvedStreamHandle<String>) {
      return createInlet<String>(handle);
    }
    return null;
  }

  /// {@macro destroy_streams}
  void destroyStreams() {
    return _streamAdapter.destroyStreams();
  }
}
