part of '../../main.dart';

enum StreamType {
  marker,
  gyroscope,
  accelerometer,
  polar,
  muse;
}

const batchSize = 20;

typedef Device = (String name, StreamType streamType, bool active);

class OutletProvider extends ChangeNotifier {
  Map<String, Device> devices = {};

  String? selectedDevice;
  Map<String, (StreamSubscription<Object?>?, StreamType)> streams = {};
  bool isWorkerListenedTo = false;
  OutletWorker? worker;
  final _museSdkPlugin = MuseSdk();
  List<String> _muses = [];

  late MyAudioHandler service;

  OutletProvider() {
    _init();
  }

  Future<void> findDevices() async {
    if (Platform.isIOS || Platform.isAndroid) {
      _addDevice("Gyroscope ${Platform.operatingSystem}", StreamType.gyroscope);
      _addDevice("Accelerometer ${Platform.operatingSystem}",
          StreamType.accelerometer);
    }

    polar.searchForDevice().listen((event) {
      _addDevice(event.deviceId, StreamType.polar);
      notifyListeners();
    });

    final granted = (await Permission.bluetoothScan.request().isGranted) &&
        (await Permission.bluetoothConnect.request().isGranted);

    if (granted && Platform.isAndroid) {
      // Only supports Android for now
      _museSdkPlugin.initialize();
      _museSdkPlugin.getConnectionStream().listen((muses) {
        if (muses == null) return;

        for (var muse in muses) {
          _addDevice(muse, StreamType.muse);
          _muses = muses;
        }
      });
    }

    notifyListeners();
  }

  updateDeviceName(String? oldName, String newName) {
    if (oldName == null) return;
    final oldDevice = devices[oldName];
    if (oldDevice == null) return;

    devices[newName] = (newName, oldDevice.$2, oldDevice.$3);
    devices.remove(oldName);
  }

  Future<void> addStream(OutletConfigDto config) async {
    worker ??= await OutletWorker.spawn();

    _audioPlay();

    switch (config.streamType) {
      case StreamType.marker:
        addMarkerStream(config);
      case StreamType.gyroscope:
        addGyroscopeStream(config);
      case StreamType.accelerometer:
        addAccelerometerStream(config);
      case StreamType.polar:
        addPolarStream(config.name, config);
      case StreamType.muse:
        addMuseStream(config.name, config);
    }

    _activate(config);
    notifyListeners();
  }

  /// Creates and subscribes to a gyroscope data stream
  void addGyroscopeStream(OutletConfigDto config) async {
    List<List<double>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    final result = await worker?.addStream(
        _createDoubleStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final subscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
            .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        timestampBuffer.add(DartTimestamp(event.timestamp));

        if (buffer.length >= batchSize) {
          if (config.useLslTimestamps) {
            worker?.pushChunk(config.name, buffer);
          } else {
            worker?.pushChunkWithTimestamps(
                config.name, buffer, timestampBuffer);
          }
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[config.name] = (subscription, StreamType.gyroscope);
  }

  /// Creates and subscribes to an accelerometer data stream
  void addAccelerometerStream(OutletConfigDto config) async {
    List<List<double>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    final result = await worker?.addStream(
        _createDoubleStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final subscription = userAccelerometerEventStream(
            samplingPeriod: SensorInterval.normalInterval)
        .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        timestampBuffer.add(DartTimestamp(event.timestamp));

        if (buffer.length >= batchSize) {
          if (config.useLslTimestamps) {
            worker?.pushChunk(config.name, buffer);
          } else {
            worker?.pushChunkWithTimestamps(
                config.name, buffer, timestampBuffer);
          }
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[config.name] = (subscription, StreamType.accelerometer);
  }

  /// Creates and subscribes to a Polar data stream
  void addPolarStream(String deviceId, OutletConfigDto config) async {
    List<List<int>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    polar.connectToDevice(deviceId);

    try {
      await polar.sdkFeatureReady.firstWhere((e) =>
          e.identifier == deviceId &&
          e.feature == PolarSdkFeature.onlineStreaming);
    } catch (e) {
      developer.log("$e");
    }

    final result = await worker?.addStream(
        _createIntStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final subscription = polar.startPpgStreaming(deviceId).listen(
      (event) {
        buffer.addAll(event.samples.map((item) => item.channelSamples));
        timestampBuffer.addAll(
            event.samples.map((item) => DartTimestamp(item.timeStamp.toUtc())));

        if (buffer.length >= batchSize) {
          if (config.useLslTimestamps) {
            worker?.pushChunk(config.name, buffer);
          } else {
            worker?.pushChunkWithTimestamps(
                config.name, buffer, timestampBuffer);
          }
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[config.name] = (subscription, StreamType.polar);
  }

  /// Creates and subscribes to a Muse data stream
  void addMuseStream(String deviceId, OutletConfigDto config) async {
    List<List<double>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    await _museSdkPlugin.connect(_muses.indexOf(deviceId));

    final result = await worker?.addStream(
        _createDoubleStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final subscription = _museSdkPlugin.getPpgStream().listen(
      (event) {
        if (event == null) return;

        buffer.addAll(event.map((item) => item.$2));
        timestampBuffer.addAll(event.map((item) => DartTimestamp(item.$1)));

        if (buffer.length >= batchSize) {
          if (config.useLslTimestamps) {
            worker?.pushChunk(config.name, buffer);
          } else {
            worker?.pushChunkWithTimestamps(
                config.name, buffer, timestampBuffer);
          }
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[config.name] = (subscription, StreamType.muse);
  }

  void pushMarkers(List<String> markers) async {
    final markerName = devices.entries
        .firstWhere((entry) => entry.value.$2 == StreamType.marker)
        .value
        .$1;

    await worker?.pushSample(markerName, markers);
  }

  void addMarkerStream(OutletConfigDto config) async {
    final result = await worker?.addStream(
        _createStringStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    streams[config.name] = (null, StreamType.marker);
  }

  void stopStream(String name) {
    // Called before stream is removed as markers don't have Dart streams.
    _deactivate(name);

    final stream = streams[name];
    if (stream == null) return;

    stream.$1?.cancel();
    if (stream.$2 == StreamType.polar) {
      polar.disconnectFromDevice(name);
    }

    if (stream.$2 == StreamType.muse) {
      // Disconnects all Muse devices
      _museSdkPlugin.disconnect();
    }

    streams.remove(name);
    _deactivate(name);

    if (streams.isEmpty) {
      worker?.close();
      worker = null;
      _audioStop();
    }

    notifyListeners();
  }

  void stopStreams() {
    _audioStop();

    for (var stream in streams.entries) {
      stream.value.$1?.cancel();
      if (stream.value.$2 == StreamType.polar) {
        polar.disconnectFromDevice(stream.key);
      }
    }
    // Disconnects all Muse devices
    _museSdkPlugin.disconnect();
    worker?.close();
    worker = null;
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }

  _init() async {
    service = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'dk.dtu.sensors.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
          // androidStopForegroundOnPause: false,
        ));
  }

  _audioPlay() {
    if (Platform.isIOS) service.play();
  }

  _audioStop() {
    if (Platform.isIOS) service.stop();
  }

  _addDevice(String name, StreamType streamType) {
    if (devices.containsKey(name)) return;

    devices[name] = ((name, streamType, false));
  }

  OutletConfig _getConfig(OutletConfigDto configDto) {
    return OutletConfig(configDto.chunkSize, configDto.maxBuffered,
        configDto.mode, configDto.offsetCalculationInterval);
  }

  void _activate(OutletConfigDto config) {
    var oldDevice = devices[config.name];
    if (oldDevice == null) {
      devices[config.name] = (config.name, config.streamType, true);
    } else {
      devices[config.name] = (oldDevice.$1, oldDevice.$2, true);
    }
  }

  void _deactivate(String name) {
    var oldDevice = devices[name];
    if (oldDevice == null) return;

    devices[name] = (oldDevice.$1, oldDevice.$2, false);
  }

  StreamInfo<double> _createDoubleStreamInfo(OutletConfigDto config) {
    return StreamInfoFactory.createDoubleStreamInfo(
        config.name, config.type, config.channelFormat as ChannelFormat<double>,
        channelCount: config.channelCount,
        nominalSRate: config.nominalSRate,
        sourceId: config.sourceId);
  }

  StreamInfo<int> _createIntStreamInfo(OutletConfigDto config) {
    return StreamInfoFactory.createIntStreamInfo(
        config.name, config.type, config.channelFormat as ChannelFormat<int>,
        channelCount: config.channelCount,
        nominalSRate: config.nominalSRate,
        sourceId: config.sourceId);
  }

  StreamInfo<String> _createStringStreamInfo(OutletConfigDto config) {
    return StreamInfoFactory.createStringStreamInfo(
        config.name, config.type, config.channelFormat as ChannelFormat<String>,
        channelCount: config.channelCount,
        nominalSRate: config.nominalSRate,
        sourceId: config.sourceId);
  }
}
