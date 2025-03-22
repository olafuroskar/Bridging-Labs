part of '../../lsl_plugin.dart';

class StreamManager {
  // TODO: Is this ok? I don't want multiple adapters going because of memory mgmt
  StreamAdapter? _streamAdapter;

  StreamManager() {
    _streamAdapter = AsyncStreamAdapter();
  }

  // TODO: AsyncResult?
  Future<List<ResolvedStreamHandle>> resolveStreams(double waitTime) {
    switch (getStreamAdapter(_streamAdapter)) {
      case Ok(value: final streamAdapter):
        return streamAdapter.resolveStreams(waitTime);
      case Error(error: var e):
        throw e;
    }
  }
}
