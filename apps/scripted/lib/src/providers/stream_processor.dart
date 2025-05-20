import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:lsl_flutter/lsl_flutter.dart';

class StreamProcessor {
  // Tied to instances
  final SendPort _commands;
  final ReceivePort _responses;

  // Active requests maps
  final Map<int, Completer<bool>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;
  StreamController<(Sample<double> slow, Sample<double> fast)>?
      _streamController;

  static double _toleranceInSeconds = 0.25;
  static double _slowThreshold = 0;
  static double _fastThreshold = 0;

  /// Are there any active requests
  bool get areActiveRequestsEmpty => _activeRequests.isEmpty;

  void process(Chunk<double> slowBuffer, Chunk<double> fastBuffer) async {
    if (_closed) throw StateError('Closed');

    _commands.send((slowBuffer, fastBuffer, null));
  }

  Future<Stream<(Sample<double> slow, Sample<double> fast)>?> startMarkerStream(
      {required Function() onCancel}) async {
    if (_closed) throw StateError('Closed');

    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;

    _streamController =
        StreamController<(Sample<double> slow, Sample<double> fast)>();

    _commands.send((null, null, id));
    final success = await completer.future;

    if (success) {
      _streamController?.onCancel = onCancel;
    }

    return _streamController?.stream;
  }

  static setThresholds(
      double slowThreshold, double fastThreshold, double toleranceInSeconds) {
    _slowThreshold = slowThreshold;
    _fastThreshold = fastThreshold;
    _toleranceInSeconds = toleranceInSeconds;
  }

  static Future<StreamProcessor> spawn() async {
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

    return StreamProcessor._(receivePort, sendPort);
  }

  StreamProcessor._(this._responses, this._commands) {
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

  void _handleResponsesFromIsolate(message) {
    final (id, response) = message as (int?, Object?);

    if (response is (Sample<double>, Sample<double>)) {
      _streamController?.add(response);
    }

    if (id != null) {
      final completer = _activeRequests.remove(id)!;
      _handleResponse(completer, response);
    }

    if (_closed && areActiveRequestsEmpty) {
      _responses.close();
    }
  }

  /// Handles commands that are sent from the main isolate to the processor.
  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) async {
    final StreamManager streamManager = StreamManager();
    final StreamController<(Sample<double> slow, Sample<double> fast)>
        controller = StreamController();

    // Listen to messages *from* the main isolate
    receivePort.listen((message) {
      if (message == 'shutdown') {
        streamManager.destroyStreams();
        receivePort.close();
        return;
      }

      void sendMessageFromWorker({
        int? id,
        Object? response,
      }) {
        sendPort.send((id, response));
      }

      final (
        slowBuffer,
        fastBuffer,
        id,
      ) = message as (
        Chunk<double>?,
        Chunk<double>?,
        int?,
      );

      try {
        if (slowBuffer != null && fastBuffer != null) {
          final result = _criteriaMet(slowBuffer, fastBuffer);
          if (result != null) {
            controller.add(result);
          }
        } else if (id != null) {
          controller.stream.listen((samples) {
            sendMessageFromWorker(
              response: samples,
            );
          });
          sendMessageFromWorker(id: id, response: true);
        }
      } catch (e) {
        log(e.toString());
      }
    });
  }

  static (Sample<double> slow, Sample<double> fast)? _criteriaMet(
      Chunk<double> slowBuffer, Chunk<double> fastBuffer) {
    for (final slow in slowBuffer) {
      for (var i = 0; i < fastBuffer.length; i += 5) {
        final fast = fastBuffer[i];
        // for (final fast in fastBuffer) {
        if ((fast.$2 - slow.$2).abs() <= _toleranceInSeconds) {
          if (fast.$1[0] < _fastThreshold && slow.$1[0] < _slowThreshold) {
            return (slow, fast);
          }
        }
      }
    }
    return null;
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
