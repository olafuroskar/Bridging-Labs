part of '../../lsl_flutter.dart';

enum InletCommandType {
  resolve("RESOLVE"),
  open("OPEN"),
  startSampleStream("START_SAMPLE_STREAM"),
  startChunkStream("START_CHUNK_STREAM"),
  startTimeCorrection("START_TIME_CORRECTION"),
  close("CLOSE_STREAM"),
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
  final Map<int, Completer<List<ResolvedStreamHandle>>> _activeHandleRequests =
      {};

  /// Keeps track of (Dart) streams which yield LSL samples
  final Map<String, StreamController<Sample<Object?>>> _activeSampleRequests =
      {};

  /// Keeps track of (Dart) streams which yield LSL chunks
  final Map<String, StreamController<Chunk<Object?>>> _activeChunkRequests = {};

  /// Keeps track of (Dart) streams which yield LSL time correction offsets
  final Map<String, StreamController<TimeOffset>>
      _activeTimeCorrectionRequests = {};

  int _idCounter = 0;
  bool _closed = false;

  /// Has the post processing option of the inlet been set to automatically synchronise the stream?
  bool _isAutoSync = false;

  final Map<String, ResolvedStreamHandle> _streams = {};
  final Set<String> _activeInlets = {};

  /// Are there any active requests
  bool get areActiveRequestsEmpty =>
      _activeRequests.isEmpty &&
      _activeHandleRequests.isEmpty &&
      _activeSampleRequests.isEmpty &&
      _activeChunkRequests.isEmpty &&
      _activeTimeCorrectionRequests.isEmpty;

  void _sendCommand<T extends Object?>(int id, InletCommandType command,
      {String? streamId,
      double? waitTime,
      bool? synchronize,
      String? prop,
      String? value,
      String? pred}) {
    _commands.send(
        (id, command, streamId, waitTime, synchronize, prop, value, pred));
  }

  /// Discover streams on the network
  ///
  /// [waitTime] Maximum wait time in seconds
  Future<List<ResolvedStreamHandle>> resolveStreams(
      {double waitTime = 2}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<List<ResolvedStreamHandle>>.sync();
    final id = _idCounter++;
    _activeHandleRequests[id] = completer;
    _sendCommand(id, InletCommandType.resolve, waitTime: waitTime);
    final handles = await completer.future;

    // Add the resolved streams to the streams list for lookup
    if (handles.isNotEmpty) {
      for (final handle in handles) {
        _streams[handle.id] = handle;
      }
    }

    return handles;
  }

  /// Discover streams on the network by stream property
  ///
  /// [waitTime] Maximum wait time in seconds
  Future<List<ResolvedStreamHandle>> resolveStreamsByProp(
      String prop, String value,
      {double waitTime = 2}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<List<ResolvedStreamHandle>>.sync();
    final id = _idCounter++;
    _activeHandleRequests[id] = completer;
    _sendCommand(id, InletCommandType.resolve,
        waitTime: waitTime, prop: prop, value: value);
    final handles = await completer.future;

    // Add the resolved streams to the streams list for lookup
    if (handles.isNotEmpty) {
      for (final handle in handles) {
        _streams[handle.id] = handle;
      }
    }

    return handles;
  }

  /// Discover streams on the network that match a given predicate
  ///
  /// [waitTime] Maximum wait time in seconds
  Future<List<ResolvedStreamHandle>> resolveStreamsByPred(String pred,
      {double waitTime = 2}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<List<ResolvedStreamHandle>>.sync();
    final id = _idCounter++;
    _activeHandleRequests[id] = completer;
    _sendCommand(id, InletCommandType.resolve, waitTime: waitTime, pred: pred);
    final handles = await completer.future;

    // Add the resolved streams to the streams list for lookup
    if (handles.isNotEmpty) {
      for (final handle in handles) {
        _streams[handle.id] = handle;
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
    _sendCommand(id, InletCommandType.open,
        streamId: streamId, synchronize: synchronize);
    final success = await completer.future;

    // Add the stream to active inlets
    if (success) {
      _activeInlets.add(streamId);
      _isAutoSync = synchronize;
    }

    return success;
  }

  /// Starts a (Dart) stream which yields samples from the specified LSL stream.
  ///
  /// [streamId] The id of the LSL stream to pull samples from.
  /// [onCancel] Cleanup function for when the stream is cancelled.
  ///
  /// The method creates a stream controller on the main isolate and the handler on the
  /// worker isolate also creates a stream which yields samples back to main isolate
  /// which further pushes them to the listener.
  Future<Stream<Sample<Object?>>> startSampleStream(String streamId,
      {required Function() onCancel}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controller's `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// samples are yielded from the worker.
    final streamController = StreamController<Sample<Object?>>();

    /// Initialise a sample stream on the inlet worker
    _sendCommand(id, InletCommandType.startSampleStream, streamId: streamId);
    final success = await completer.future;

    if (success) {
      streamController.onCancel = onCancel;
      _activeSampleRequests[streamId] = streamController;
    }

    return streamController.stream;
  }

  /// Starts a (Dart) stream which yields chunks from the specified LSL stream.
  ///
  /// [streamId] The id of the LSL stream to pull chunks from.
  /// [onCancel] Cleanup function for when the stream is cancelled.
  ///
  /// The method creates a stream controller on the main isolate and the handler on the
  /// worker isolate also creates a stream which yields chunks back to main isolate
  /// which further pushes them to the listener.
  Future<Stream<Chunk<Object?>>> startChunkStream(String streamId,
      {required Function() onCancel}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controller's `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// chunks are yielded from the worker.
    final streamController = StreamController<Chunk<Object?>>();

    /// Initialise a chunk stream on the inlet worker
    _sendCommand(id, InletCommandType.startChunkStream, streamId: streamId);
    final success = await completer.future;

    if (success) {
      streamController.onCancel = onCancel;
      _activeChunkRequests[streamId] = streamController;
    }

    return streamController.stream;
  }

  /// Starts a (Dart) stream which yields time correction offsets from the specified LSL stream.
  ///
  /// [streamId] The id of the LSL stream to pull chunks from.
  /// [onCancel] Cleanup function for when the stream is cancelled.
  ///
  /// The method creates a stream controller on the main isolate and the handler on the
  /// worker isolate also creates a stream which yields time correction offsets back to main isolate
  /// which further pushes them to the listener.
  Future<Stream<TimeOffset>> startTimeCorrectionStream(String streamId,
      {required Function() onCancel}) async {
    if (_closed) throw StateError('Closed');
    if (_isAutoSync) {
      throw StateError('Automatic synchronization has already been set');
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    /// The controller's `add` method can then be called in the [_handleResponsesFromIsolate] method when
    /// offsets are yielded from the worker.
    final streamController = StreamController<TimeOffset>();

    /// Initialise a time correction stream on the inlet worker
    _sendCommand(id, InletCommandType.startTimeCorrection, streamId: streamId);
    final success = await completer.future;

    if (success) {
      streamController.onCancel = onCancel;
      _activeTimeCorrectionRequests[streamId] = streamController;
    }

    return streamController.stream;
  }

  /// Stop pulling data from a given inlet
  ///
  /// [streamId] Id of the stream.
  ///
  /// After stop has been called, calling [close] is also recommended to clean up the inlet
  Future<bool> stop(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _sendCommand(id, InletCommandType.stop, streamId: streamId);
    final success = await completer.future;

    // Add the stream to active inlets
    if (success) {
      _activeInlets.remove(streamId);
    }

    return success;
  }

  /// Close the inlet associated to the stream.
  ///
  /// [streamId] Id of the stream.
  Future<bool> close(String streamId) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _sendCommand(id, InletCommandType.close, streamId: streamId);
    final success = await completer.future;

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
    } else if (response is TimeOffset) {
      final controller = _activeTimeCorrectionRequests[streamId]!;
      _handleStreamResponse<TimeOffset>(controller, response);
    } else if (response is List<ResolvedStreamHandle>) {
      final completer = _activeHandleRequests.remove(id)!;
      _handleResponse(completer, response);
    } else {
      if (stopping ?? false) {
        _activeSampleRequests[streamId]?.close();
        _activeSampleRequests.remove(streamId);
        _activeChunkRequests[streamId]?.close();
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

      final (id, command, streamId, waitTime, synchronize, prop, value, pred) =
          message as (
        int,
        InletCommandType,
        String?,
        double?,
        bool?,
        String?,
        String?,
        String?
      );

      try {
        switch (command) {
          case InletCommandType.resolve:
            List<ResolvedStreamHandle> resolvedStreams = [];
            if (prop != null && value != null) {
              streamManager.resolveStreamsByProp(waitTime ?? 2, prop, value, 0);
            } else if (pred != null) {
              streamManager.resolveStreamsByPred(waitTime ?? 2, pred, 0);
            } else {
              streamManager.resolveStreams(waitTime ?? 2);
            }
            resolvedStreams = streamManager.getStreamHandles();
            sendMessageFromWorker(id, resolvedStreams);
            break;
          case InletCommandType.open:
            if (streamId == null) {
              sendMessageFromWorker(id, false);
              break;
            }
            final inlet = streamManager.createInletFromId(streamId);

            if (inlet != null) {
              if (synchronize ?? false) {
                inlet.setPostProcessing(
                    [ProcessingOptions.clockSync, ProcessingOptions.dejitter]);
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
          case InletCommandType.startTimeCorrection:
            final inlet = inlets[streamId];

            final subscription =
                inlet?.startTimeCorrectionStream().listen((offset) {
              sendMessageFromWorker(id, offset, streamId: streamId);
            });
            sendMessageFromWorker(id, subscription != null, streamId: streamId);
            break;
          case InletCommandType.stop:
            inlets[streamId]?.stopStream();
            sendMessageFromWorker(id, true, streamId: streamId, stopping: true);
            break;
          case InletCommandType.close:
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

  /// Shuts down the worker
  void shutdown() {
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
