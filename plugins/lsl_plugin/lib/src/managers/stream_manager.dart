part of 'managers.dart';

class StreamManager {
  final StreamAdapter _streamAdapter = AsyncStreamAdapter();

  StreamManager();

  // TODO: AsyncResult?
  Future<void> resolveStreams(double waitTime) {
    switch (getStreamAdapter(_streamAdapter)) {
      case Ok(value: final streamAdapter):
        return streamAdapter.resolveStreams(waitTime);
      case Error(error: var e):
        throw e;
    }
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

  Result<InletManager<S>> createInlet<S>(ResolvedStreamHandle<S> handle) {
    switch (getStreamAdapter(_streamAdapter)) {
      case Ok(value: final streamAdapter):
        // TODO: Handle exception
        final inletAdapter = streamAdapter.createInlet<S>(handle);
        final inletManager = InletManager<S>._(inletAdapter);

        return Result.ok(inletManager);
      case Error(error: var e):
        throw e;
    }
  }
}
