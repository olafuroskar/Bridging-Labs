import 'package:flutter/services.dart';

import 'muse_sdk_platform_interface.dart';

class MuseSdk {
  static const _eventChannel = EventChannel('muse_sdk/events');
  static const _dataEventsChannel = EventChannel('muse_sdk/data_events');

  Future<String?> getPlatformVersion() {
    return MuseSdkPlatform.instance.getPlatformVersion();
  }

  Stream<dynamic> getMuseEvents() {
    return MuseSdkPlatform.instance.getMuseEvents();
  }

  void initialize() {
    return MuseSdkPlatform.instance.initialize();
  }

  Future<bool> isBluetoothEnabled() {
    return MuseSdkPlatform.instance.isBluetoothEnabled();
  }

  void refreshMuseList() async {
    return MuseSdkPlatform.instance.refreshMuseList();
  }

  Future<void> connect(int muse) async {
    return MuseSdkPlatform.instance.connect(muse);
  }

  void disconnect() async {
    return MuseSdkPlatform.instance.disconnect();
  }

  Stream<List<String>?> getConnectionStream() {
    return _eventChannel.receiveBroadcastStream().map<List<String>?>((event) {
      if (event['type'] == 'museListChanged') {
        return List<String>.from(event['muses']);
      }
      return null;
    });
  }

  /// Sets up a broadcast stream for receiving PPG data events
  ///
  /// Each data item contains a red, infrared and ambient channels
  Stream<List<(DateTime, List<double>)>?> getPpgStream() {
    return _dataEventsChannel
        .receiveBroadcastStream()
        .map<List<(DateTime, List<double>)>?>((event) {
      if (event['type'] == "ppg") {
        final data = List<dynamic>.from(event['data']);

        return data
            .map((datum) => (
                  DateTime.fromMicrosecondsSinceEpoch(
                      datum['timestamp'] as int),
                  List<double>.from(datum['values'])
                ))
            .toList();
      }
      return null;
    });
  }
}
