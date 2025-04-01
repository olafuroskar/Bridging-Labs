import 'dart:async';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:sensors_plus/sensors_plus.dart';

enum CommandType {
  start("START"),
  push("PUSH"),
  pushWithTimestamp("PUSH_WITH_TIMESTAMP"),
  stop("STOP");

  const CommandType(this.value);
  final String value;
}

class _IsolateData {
  final RootIsolateToken rootIsolateToken;
  final SendPort sendPort;

  _IsolateData(this.rootIsolateToken, this.sendPort);
}

/// https://dart.dev/language/isolates
class Worker2 {
  // Tied to instances
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<bool>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Future<bool> addDevice(String deviceId) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, CommandType.start, deviceId, null, null));
    return await completer.future;
  }

  Future<bool> pushChunk(String deviceId, List<List<Object?>> chunk) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, CommandType.push, deviceId, chunk, null));
    return await completer.future;
  }

  Future<bool> pushChunkWithTimestamp(String deviceId,
      List<List<Object?>> chunk, List<double> timestamps) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands
        .send((id, CommandType.pushWithTimestamp, deviceId, chunk, timestamps));
    return await completer.future;
  }

  Future<bool> removeDevice(String deviceId) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<bool>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, CommandType.stop, deviceId, null, null));
    return await completer.future;
  }

  static Future<Worker2> spawn() async {
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

    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate,
          _IsolateData(rootIsolateToken, initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return Worker2._(receivePort, sendPort);
  }

  Worker2._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
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

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    // Keep track of outets and stream subscriptions
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
        int id,
        CommandType command,
        String deviceId,
        List<List<Object?>>? chunk,
        List<double>? timestamps
      ) = message as (
        int,
        CommandType,
        String,
        List<List<Object?>>?,
        List<double>?
      );
      try {
        switch (command) {
          case CommandType.start:
            final result = addStream(deviceId);
            sendPort.send((id, result != null));
            if (result != null) {
              outlets[deviceId] = result;
            }
            break;
          case CommandType.push:
            // print("$id, $command, $deviceId, $chunk");

            if (chunk != null) {
              outlets[deviceId]?.pushChunk(chunk);
              sendPort.send((id, true));
            } else {
              sendPort.send((id, false));
            }
            break;
          case CommandType.pushWithTimestamp:
            if (chunk != null && timestamps != null) {
              outlets[deviceId]?.pushChunkWithTimastamps(chunk, timestamps);
              sendPort.send((id, true));
            } else {
              sendPort.send((id, false));
            }
            break;
          case CommandType.stop:
            outlets[deviceId]?.destroy();
            outlets.remove(deviceId);
            sendPort.send((id, true));
            break;
        }
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  static void _startRemoteIsolate(
    _IsolateData isolatData,
  ) {
    final sendPort = isolatData.sendPort;
    final rootIsolateToken = isolatData.rootIsolateToken;

    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      print('--- port closed --- ');
    }
  }

  static OutletManager<Object?>? addStream(String deviceId) {
    if (deviceId == "Gyroscope") {
      return _addGyroscopeStream(deviceId);
    } else if (deviceId == "Accelerometer") {
      return _addUserAccelerometer(deviceId);
    } else {
      return _addPolarStream(deviceId);
    }
  }

  static OutletManager<Object?>? _addGyroscopeStream(String deviceId) {
    OutletManager<double>? outletManager;

    try {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Gyroscope mobile", "Gyroscope", Double64ChannelFormat(),
          channelCount: 3,
          nominalSRate:
              SensorInterval.normalInterval.inMilliseconds.toDouble() / 1000,
          sourceId: deviceId);
      outletManager = OutletManager(streamInfo);

      return outletManager;
    } catch (e) {
      print("Stream creation failed: $e");
      return null;
    }
  }

  static OutletManager<Object?>? _addUserAccelerometer(String deviceId) {
    OutletManager<double>? outletManager;

    try {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Accelerometer mobile", "Accelerometer", Double64ChannelFormat(),
          channelCount: 3,
          nominalSRate:
              SensorInterval.normalInterval.inMilliseconds.toDouble() / 1000,
          sourceId: deviceId);
      outletManager = OutletManager(streamInfo, 50);

      return outletManager;
    } catch (e) {
      print("Stream creation failed: $e");
      return null;
    }
  }

  static OutletManager<Object?>? _addPolarStream(String deviceId) {
    OutletManager<int>? outletManager;

    try {
      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Polar $deviceId", "PPG", Int64ChannelFormat(),
          channelCount: 4,
          nominalSRate:
              // TODO: Not sure this is right
              SensorInterval.normalInterval.inMilliseconds.toDouble() / 1000,
          sourceId: deviceId);
      outletManager = OutletManager(streamInfo, 1);

      return outletManager;
    } catch (e) {
      print("$e");
      outletManager?.destroy();
      return null;
    }
  }
}
