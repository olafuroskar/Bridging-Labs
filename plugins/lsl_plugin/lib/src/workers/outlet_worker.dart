part of '../../lsl_plugin.dart';

enum OutletCommandType {
  start("START"),
  pushSample("PUSH_SAMPLE"),
  pushChunk("PUSH_CHUNK"),
  pushChunkWithTimestamp("PUSH_CHUNK_WITH_TIMESTAMP"),
  stop("STOP");

  const OutletCommandType(this.value);
  final String value;
}

class IsolateArguments {
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  IsolateArguments(this.sendPort, this.rootIsolateToken);
}

/// An isolate worker class for outlets
///
/// Spawns an isolate which handles keeping track of and pushing to streams.
/// Based on https://dart.dev/language/isolates
class OutletWorker {
  // Tied to instances
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<bool>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Map<String, StreamInfo> streams = {};

  void sendCommand<T extends Object?>(int id, OutletCommandType command,
      {String? name,
      StreamInfo<Object?>? streamInfo,
      List<T>? sample,
      Timestamp? timestamp,
      List<List<T>>? chunk,
      List<Timestamp>? timestamps}) {
    _commands.send((
      id,
      command,
      name,
      streamInfo is StreamInfo<int> ? streamInfo : null,
      streamInfo is StreamInfo<double> ? streamInfo : null,
      streamInfo is StreamInfo<String> ? streamInfo : null,
      sample is List<int> ? sample : null,
      sample is List<double> ? sample : null,
      sample is List<String> ? sample : null,
      timestamp,
      chunk is List<List<int>> ? chunk : null,
      chunk is List<List<double>> ? chunk : null,
      chunk is List<List<String>> ? chunk : null,
      timestamps
    ));
  }

  /// Add a new stream outlet
  ///
  /// [streamInfo] contains the necessary information about the stream.
  /// [streamInfo.name] must be unique
  Future<bool> addStream(StreamInfo streamInfo) async {
    if (_closed) throw StateError('Closed');
    if (streams.containsKey(streamInfo.name)) {
      throw Exception("Stream with name ${streamInfo.name} already exists");
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, OutletCommandType.start,
        name: streamInfo.name, streamInfo: streamInfo);
    final success = await completer.future;

    // If outlet is created successfully the stream is added to the current state
    if (success) {
      streams[streamInfo.name] = streamInfo;
    }

    return success;
  }

  /// Push a sample of data to the given stream
  ///
  /// [name] The name of the stream
  /// [sample] Data to be pushed to the stream
  /// [timestamp] Optional user provided timestamp
  Future<bool> pushSample(
      String name, List<Object?> sample, Timestamp? timestamp) async {
    if (_closed) throw StateError('Closed');
    if (!streams.containsKey(name)) {
      throw Exception("Stream with name $name does not exists");
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, OutletCommandType.pushChunk,
        name: name, sample: sample, timestamp: timestamp);
    return await completer.future;
  }

  /// Push a chunk of data to the given stream
  ///
  /// [name] The name of the stream
  /// [chunk] Data to be pushed to the stream
  Future<bool> pushChunk(String name, List<List<Object?>> chunk) async {
    if (_closed) throw StateError('Closed');
    if (!streams.containsKey(name)) {
      throw Exception("Stream with name $name does not exists");
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, OutletCommandType.pushChunk, name: name, chunk: chunk);
    return await completer.future;
  }

  /// Push a chunk of data to the given stream, with timestamps per sample
  ///
  /// [name] The name of the stream
  /// [chunk] Data to be pushed to the stream
  /// [timestamps] Timestamps per sample
  Future<bool> pushChunkWithTimestamp(String name, List<List<Object?>> chunk,
      List<Timestamp> timestamps) async {
    if (_closed) throw StateError('Closed');
    if (!streams.containsKey(name)) {
      throw Exception("Stream with name $name does not exists");
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, OutletCommandType.pushChunkWithTimestamp,
        name: name, chunk: chunk, timestamps: timestamps);
    return await completer.future;
  }

  /// Remove a given stream
  ///
  /// [name] The name of the stream to be removed
  Future<bool> removeStream(String name) async {
    if (_closed) throw StateError('Closed');
    if (!streams.containsKey(name)) {
      throw Exception("Stream with name $name does not exists");
    }

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    sendCommand(id, OutletCommandType.stop, name: name);

    final result = await completer.future;
    if (result) {
      streams.remove(name);
    }
    return result;
  }

  /// Spawns a new outlet worker
  static Future<OutletWorker> spawn() async {
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
      await Isolate.spawn(_startRemoteIsolate,
          IsolateArguments(initPort.sendPort, RootIsolateToken.instance!));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return OutletWorker._(receivePort, sendPort);
  }

  OutletWorker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else if (response is bool) {
      completer.complete(response);
    } else {
      completer.completeError("Unexpected response type from isolate");
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  /// Handles commands that are sent from the main isolate to the outlet isolate.
  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    /// Keep track of outets and stream subscriptions
    ///
    /// This map needs to be in the scope of this handler. Isolate do not share memory
    /// with each other so defining it outside this function may cause unexpected behaviour.
    final Map<String, OutletManager<Object?>> outlets = {};

    // Listen to messages *from* the main isolate
    receivePort.listen((message) {
      if (message == 'shutdown') {
        for (var outlet in outlets.values) {
          outlet.destroy();
        }
        outlets.clear();
        receivePort.close();
        return;
      }
      final (
        id,
        command,
        name,
        intStreamInfo,
        doubleStreamInfo,
        stringStreamInfo,
        intSample,
        doubleSample,
        stringSample,
        timestamp,
        intChunk,
        doubleChunk,
        stringChunk,
        timestamps
      ) = message as (
        int,
        OutletCommandType,
        String,
        StreamInfo<int>?,
        StreamInfo<double>?,
        StreamInfo<String>?,
        List<int>?,
        List<double>?,
        List<String>?,
        Timestamp?,
        List<List<int>>?,
        List<List<double>>?,
        List<List<String>>?,
        List<Timestamp>?
      );
      try {
        switch (command) {
          case OutletCommandType.start:
            OutletManager? manager;
            if (intStreamInfo != null) {
              manager = _addStream<int>(intStreamInfo);
            } else if (doubleStreamInfo != null) {
              manager = _addStream<double>(doubleStreamInfo);
            } else if (stringStreamInfo != null) {
              manager = _addStream<String>(stringStreamInfo);
            }

            if (manager != null) {
              outlets[name] = manager;
            }
            sendPort.send((id, manager != null));
            break;
          case OutletCommandType.pushSample:
            if (intSample != null) {
              outlets[name]?.pushSample(intSample, timestamp);
            } else if (doubleSample != null) {
              outlets[name]?.pushSample(doubleSample, timestamp);
            } else if (stringSample != null) {
              outlets[name]?.pushSample(stringSample, timestamp);
            } else {
              sendPort.send((id, false));
              break;
            }
            sendPort.send((id, true));
            break;
          case OutletCommandType.pushChunk:
            if (intChunk != null) {
              outlets[name]?.pushChunk(intChunk);
            } else if (doubleChunk != null) {
              outlets[name]?.pushChunk(doubleChunk);
            } else if (stringChunk != null) {
              outlets[name]?.pushChunk(stringChunk);
            } else {
              sendPort.send((id, false));
              break;
            }
            sendPort.send((id, true));
            break;
          case OutletCommandType.pushChunkWithTimestamp:
            if (timestamps == null) {
              sendPort.send((id, false));
              break;
            }
            if (intChunk != null) {
              outlets[name]?.pushChunkWithTimestamps(intChunk, timestamps);
            } else if (doubleChunk != null) {
              outlets[name]?.pushChunkWithTimestamps(doubleChunk, timestamps);
            } else if (stringChunk != null) {
              outlets[name]?.pushChunkWithTimestamps(stringChunk, timestamps);
            } else {
              sendPort.send((id, false));
              break;
            }
            sendPort.send((id, true));
            break;
          case OutletCommandType.stop:
            outlets[name]?.destroy();
            outlets.remove(name);
            sendPort.send((id, true));
            break;
        }
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  /// Creates the needed ports for the worker and sends them back to the main isolate
  static void _startRemoteIsolate(IsolateArguments args) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(args.rootIsolateToken);

    final receivePort = ReceivePort();
    args.sendPort.send(receivePort.sendPort);

    /// Initialise the handler
    _handleCommandsToIsolate(receivePort, args.sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      log('--- port closed --- ');
    }
  }

  /// Creates an outlet manager
  static OutletManager<T>? _addStream<T>(StreamInfo<T> streamInfo) {
    try {
      return OutletManager(streamInfo);
    } catch (e) {
      log("Stream creation failed: $e");
      return null;
    }
  }
}
