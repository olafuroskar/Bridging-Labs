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
      {String? streamId, double? waitTime, bool? synchronize}) {
    _commands.send((id, command, streamId, waitTime, synchronize));
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
  Future<bool> open(String streamId, {bool synchronize = false}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, InletCommandType.open,
        streamId: streamId, synchronize: synchronize);
    final success = await completer.future;

    // Add the stream to active inlets
    if (success) {
      activeInlets.add(streamId);
    }

    return success;
  }

  /// Starts a (Dart) stream which yields samples from the specified LSL stream.
  ///
  /// [streamId] The id of the LSL stream to pull samples from.
  ///
  /// The method creates a stream controller on the main isolate and the handler on the
  /// worker isolate also creates a stream which yields samples back to main isolate
  /// which further pushes them to the listener.
  Future<Stream<Sample<Object?>>> startSampleStream(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controller's `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// samples are yielded from the worker.
    final streamController = StreamController<Sample<Object?>>();

    /// Initialise a sample stream on the inlet worker
    sendCommand(id, InletCommandType.startSampleStream, streamId: streamId);
    final success = await completer.future;

    if (success) {
      _activeSampleRequests[streamId] = streamController;
    }

    return streamController.stream;
  }

  /// Starts a (Dart) stream which yields chunks from the specified LSL stream.
  ///
  /// [streamId] The id of the LSL stream to pull chunks from.
  ///
  /// The method creates a stream controller on the main isolate and the handler on the
  /// worker isolate also creates a stream which yields chunks back to main isolate
  /// which further pushes them to the listener.
  Future<Stream<Chunk<Object?>>> startChunkStream(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controller's `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// chunks are yielded from the worker.
    final streamController = StreamController<Chunk<Object?>>();

    /// Initialise a chunk stream on the inlet worker
    sendCommand(id, InletCommandType.startChunkStream, streamId: streamId);
    final success = await completer.future;

    if (success) {
      _activeChunkRequests[streamId] = streamController;
    }

    return streamController.stream;
  }

  Future<bool> stop(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, InletCommandType.stop, streamId: streamId);
    final success = await completer.future;

    // Add the stream to active inlets
    if (success) {
      activeInlets.add(streamId);
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

  /// Handles responses for completers
  void _handleResponse<T>(Completer<T> completer, Object? response) {
    if (response is RemoteError) {
      completer.completeError(response);
    } else if (response is T) {
      completer.complete(response);
    } else {
      completer.completeError("Unexpected response type from isolate");
    }
  }

  /// Handles responses for stream controllers
  void _handleStreamResponse<T>(StreamController<T> controller, T data) {
    controller.add(data);
  }

  void _handleResponsesFromIsolate(message) {
    final (id, response, streamId, stopping) =
        message as (int, Object?, String?, bool?);

    if (response is Sample<Object?>) {
      final controller = _activeSampleRequests[streamId]!;
      _handleStreamResponse<Sample<Object?>>(controller, response);
    } else if (response is Chunk<Object?>) {
      final controller = _activeChunkRequests[streamId]!;
      _handleStreamResponse<Chunk<Object?>>(controller, response);
    } else if (response is List<ResolvedStreamHandle<Object?>>) {
      final completer = _activeHandleRequests.remove(id)!;
      _handleResponse(completer, response);
    } else {
      if (stopping ?? false) {
        _activeSampleRequests.remove(streamId);
        _activeChunkRequests.remove(streamId);
      }
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

    void sendMessageFromWorker(int id, Object? response,
        {String? streamId, bool stopping = false}) {
      sendPort.send((id, response, streamId, stopping));
    }

    // Listen to messages *from* the main isolate
    receivePort.listen((message) {
      if (message == 'shutdown') {
        streamManager.destroyStreams();
        receivePort.close();
        return;
      }

      final (id, command, streamId, waitTime, synchronize) =
          message as (int, InletCommandType, String?, double?, bool?);

      try {
        switch (command) {
          case InletCommandType.resolve:
            List<ResolvedStreamHandle<Object?>> resolvedStreams = [];
            streamManager.resolveStreams(waitTime ?? 2);
            resolvedStreams = streamManager.getStreamHandles();
            sendMessageFromWorker(id, resolvedStreams);
            break;
          case InletCommandType.open:
            if (streamId == null) {
              sendMessageFromWorker(id, false);
              break;
            }
            final inlet = streamManager.createInletFromId(streamId);

            // print("The inlet $streamId");
            if (inlet != null) {
              if (synchronize ?? false) {
                print("=== 1 ===");
                inlet.getStreamInfo();
                print("=== 2 ===");
                inlet.setPostProcessing(
                    [ProcessingOptions.clockSync, ProcessingOptions.dejitter]);
                print("=== 3 ===");
                inlet.getStreamInfo();
                print("=== 4 ===");
              }
              inlet.openStream();
              inlets[streamId] = inlet;
            }

            sendMessageFromWorker(id, inlet != null, streamId: streamId);
            break;
          case InletCommandType.startSampleStream:
            final inlet = inlets[streamId];

            final subscription = inlet?.startSampleStream().listen((sample) {
              sendMessageFromWorker(id, sample, streamId: streamId);
            });
            sendMessageFromWorker(id, subscription != null, streamId: streamId);
            break;
          case InletCommandType.startChunkStream:
            final inlet = inlets[streamId];

            final subscription = inlet?.startChunkStream().listen((chunk) {
              sendMessageFromWorker(id, chunk, streamId: streamId);
            });
            sendMessageFromWorker(id, subscription != null, streamId: streamId);
            break;
          case InletCommandType.stop:
            inlets[streamId]?.closeStream();
            inlets.remove(streamId);
            sendMessageFromWorker(id, true, streamId: streamId);
            break;
        }
      } catch (e) {
        sendMessageFromWorker(id, RemoteError(e.toString(), ''),
            streamId: streamId);
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
