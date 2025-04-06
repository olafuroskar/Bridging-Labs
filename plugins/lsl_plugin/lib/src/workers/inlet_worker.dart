part of '../../lsl_plugin.dart';

enum InletCommandType {
  resolve("RESOLVE"),
  open("OPEN"),
  startSampleStream("START_SAMPLE_STREAM"),
  startChunkStream("START_CHUNK_STREAM"),
  stop("STOP");

  const InletCommandType(this.value);
  final String value;
}

/// An isolate worker class for inlets
///
/// Spawns an isolate which handles keeping track of and pulling from streams.
/// Based on https://dart.dev/language/isolates
class InletWorker {
  // Tied to instances
  final SendPort _commands;
  final ReceivePort _responses;

  // Active requests maps
  final Map<int, Completer<bool>> _activeRequests = {};
  final Map<int, Completer<List<ResolvedStreamHandle<Object?>>>>
      _activeHandleRequests = {};

  /// Keeps track of (Dart) streams which yield LSL samples
  final Map<String, StreamController<Sample<Object?>>> _activeSampleRequests =
      {};

  /// Keeps track of (Dart) streams which yield LSL chunks
  final Map<String, StreamController<Chunk<Object?>>> _activeChunkRequests = {};

  int _idCounter = 0;
  bool _closed = false;

  Map<String, ResolvedStreamHandle<Object?>> streams = {};
  Set<String> activeInlets = {};

  bool get areActiveRequestsEmpty =>
      _activeRequests.isEmpty &&
      _activeHandleRequests.isEmpty &&
      _activeSampleRequests.isEmpty &&
      _activeChunkRequests.isEmpty;

  void sendCommand<T extends Object?>(int id, InletCommandType command,
      {String? streamId, double? waitTime}) {
    _commands.send((
      id,
      command,
      streamId,
      waitTime,
    ));
  }

  /// Discover streams on the network
  ///
  /// [waitTime] Maximum wait time in seconds
  Future<List<ResolvedStreamHandle<Object?>>> resolveStreams(
      {double waitTime = 2}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<List<ResolvedStreamHandle<Object?>>>.sync();
    final id = _idCounter++;
    _activeHandleRequests[id] = completer;
    sendCommand(id, InletCommandType.resolve, waitTime: waitTime);
    final handles = await completer.future;

    // Add the resolved streams to the streams list for lookup
    if (handles.isNotEmpty) {
      for (final handle in handles) {
        streams[handle.id] = handle;
      }
    }

    return handles;
  }

  /// Open an inlet on a given stream.
  ///
  /// [streamId] The id of the stream on which an inlets should be opened
  Future<bool> open(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, InletCommandType.open, streamId: streamId);
    final success = await completer.future;

    // Add the stream to active inlets
    if (success) {
      activeInlets.add(streamId);
    }

    return success;
  }

  Future<bool> startSampleStream(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controllers `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// samples are yielded from the worker.
    final streamController = StreamController<Sample<Object?>>(onListen: () {
      /// Initialise a sample stream on the inlet worker
      sendCommand(id, InletCommandType.startSampleStream, streamId: streamId);
    });

    final success = await completer.future;

    if (success) {
      _activeSampleRequests[streamId] = streamController;
    }

    return success;
  }

  /// Spawns a new inlet worker
  static Future<InletWorker> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, initPort.sendPort);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return InletWorker._(receivePort, sendPort);
  }

  InletWorker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponse<T>(Completer<T> completer, Object? response) {
    if (response is RemoteError) {
      completer.completeError(response);
    } else if (response is T) {
      completer.complete(response);
    } else {
      completer.completeError("Unexpected response type from isolate");
    }
  }

  void _handleStreamResponse<T>(StreamController<T> controller, T data) {
    controller.add(data);
  }

  void _handleResponsesFromIsolate(message) {
    final (id, command, response, streamId) = message as (
      int,
      InletCommandType,
      Object?,
      String?,
    );

    if (response is Sample<Object?>) {
      final controller = _activeSampleRequests.remove(streamId)!;
      _handleStreamResponse<Sample<Object?>>(controller, response);
    } else if (response is Chunk<Object?>) {
      final controller = _activeChunkRequests.remove(streamId)!;
      _handleStreamResponse<Chunk<Object?>>(controller, response);
    } else if (command == InletCommandType.resolve) {
      final completer = _activeHandleRequests.remove(id)!;
      _handleResponse(completer, response);
    } else {
      final completer = _activeRequests.remove(id)!;
      _handleResponse(completer, response);
    }
    if (_closed && areActiveRequestsEmpty) {
      _responses.close();
    }
  }

  /// Handles commands that are sent from the main isolate to the inlet isolate.
  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    final StreamManager streamManager = StreamManager();
    final Map<String, InletManager<Object?>> inlets = {};

    // Listen to messages *from* the main isolate
    receivePort.listen((message) {
      if (message == 'shutdown') {
        streamManager.destroyStreams();
        receivePort.close();
        return;
      }

      final (id, command, streamId, waitTime) =
          message as (int, InletCommandType, String, double);

      try {
        switch (command) {
          case InletCommandType.resolve:
            List<ResolvedStreamHandle<Object?>> resolvedStreams = [];
            streamManager.resolveStreams(waitTime);
            resolvedStreams.addAll(streamManager.getStreamHandles());
            sendPort.send((id, resolvedStreams));
            break;
          case InletCommandType.open:
            final inlet = streamManager.createInletFromId(streamId);

            if (inlet != null) {
              inlet.openStream();
              inlets[streamId] = inlet;
            }

            sendPort.send((id, inlet != null));
            break;
          case InletCommandType.startSampleStream:
            final subscription =
                inlets[streamId]?.startSampleStream().listen((sample) {
              sendPort.send((id, command, sample, streamId));
            });
            sendPort.send((id, command, subscription != null, streamId));
            break;
          case InletCommandType.startChunkStream:
            final subscription =
                inlets[streamId]?.startChunkStream().listen((chunk) {
              sendPort.send((id, command, chunk, streamId));
            });
            sendPort.send((id, command, subscription != null, streamId));
            break;
          case InletCommandType.stop:
            inlets[streamId]?.closeStream();
            inlets.remove(streamId);
            sendPort.send((id, true));
            break;
        }
      } catch (e) {
        sendPort.send((id, command, RemoteError(e.toString(), '')));
      }
    });
  }

  /// Creates the needed ports for the worker and sends them back to the main isolate
  static void _startRemoteIsolate(
    SendPort sendPort,
  ) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    /// Initialise the handler
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (areActiveRequestsEmpty) {
        _responses.close();
      }
      log('--- port closed --- ');
    }
  }
}
