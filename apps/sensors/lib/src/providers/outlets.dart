part of '../../main.dart';

enum StreamType {
  device,
  polar,
  muse;
}

const batchSize = 20;
final gyroscope = "Gyroscope ${Platform.operatingSystem}";
final accelerometer = "Accelerometer ${Platform.operatingSystem}";

class OutletProvider extends ChangeNotifier {
  List<(String, StreamType)> devices = [];
  String? selectedDevice;
  Map<String, (StreamSubscription<Object?>, StreamType)> streams = {};
  bool isWorkerListenedTo = false;
  OutletWorker? worker;
  final _museSdkPlugin = MuseSdk();
  List<String> _muses = [];

  late MyAudioHandler service;

  OutletProvider() {
    print("outlet init");
    _init();
  }

  _init() async {
    print("service init");
    service = await AudioService.init(
        builder: () => MyAudioHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'dk.dtu.sensors.audio',
          androidNotificationChannelName: 'Audio Playback',
          androidNotificationOngoing: true,
          // androidStopForegroundOnPause: false,
        ));
  }

  Future<void> findDevices() async {
    if (Platform.isIOS || Platform.isAndroid) {
      devices = [
        (gyroscope, StreamType.device),
        (accelerometer, StreamType.device)
      ];
    }

    polar.searchForDevice().listen((event) {
      if (!devices.any((item) => item.$1 == event.deviceId)) {
        devices.add((event.deviceId, StreamType.polar));
        notifyListeners();
      }
    });

    final granted = (await Permission.bluetoothScan.request().isGranted) &&
        (await Permission.bluetoothConnect.request().isGranted);

    if (granted && Platform.isAndroid) {
      // Only supports Android for now
      _museSdkPlugin.initialize();
      _museSdkPlugin.getConnectionStream().listen((muses) {
        if (muses == null) return;

        for (var muse in muses) {
          devices.add((muse, StreamType.muse));
          _muses = muses;
        }
      });
    }

    notifyListeners();
  }

  Future<void> addStream(String deviceId) async {
    worker ??= await OutletWorker.spawn();

    service.play();

    if (deviceId == gyroscope) {
      addGyroscopeStream(deviceId);
    } else if (deviceId == accelerometer) {
      addAccelerometerStream(deviceId);
    } else {
      final type = devices.firstWhere((device) => deviceId == device.$1).$2;
      if (type == StreamType.polar) {
        addPolarStream(deviceId);
      } else {
        addMuseStream(deviceId);
      }
    }
  }

  void addGyroscopeStream(String deviceId) async {
    List<List<double>> buffer = [];

    final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
        deviceId, "Gyroscope", Double64ChannelFormat(),
        channelCount: 3,
        nominalSRate: intervalToFrequency(SensorInterval.normalInterval));

    final result = await worker?.addStream(streamInfo);

    if (result == null || !result) {
      return;
    }

    final subscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
            .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        if (buffer.length >= batchSize) {
          worker?.pushChunk(deviceId, buffer);
          buffer.clear();
        }
      },
    );

    streams[deviceId] = (subscription, StreamType.device);
  }

  void addAccelerometerStream(String deviceId) async {
    List<List<double>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
        deviceId, "Accelerometer", Double64ChannelFormat(),
        channelCount: 3,
        nominalSRate: intervalToFrequency(SensorInterval.normalInterval));

    final result = await worker?.addStream(streamInfo);

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
          worker?.pushChunkWithTimestamp(deviceId, buffer, timestampBuffer);
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[deviceId] = (subscription, StreamType.device);
  }

  void addPolarStream(String deviceId) async {
    List<List<int>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    polar.connectToDevice(deviceId);

    try {
      await polar.sdkFeatureReady.firstWhere((e) =>
          e.identifier == deviceId &&
          e.feature == PolarSdkFeature.onlineStreaming);
    } catch (e) {
      log("$e");
    }

    final name = "Polar $deviceId";

    final streamInfo = StreamInfoFactory.createIntStreamInfo(
        name, "PPG", Int64ChannelFormat(),
        channelCount: 4, nominalSRate: 135, sourceId: deviceId);

    final result = await worker?.addStream(streamInfo);

    if (result == null || !result) {
      return;
    }

    final subscription = polar.startPpgStreaming(deviceId).listen(
      (event) {
        buffer.addAll(event.samples.map((item) => item.channelSamples));
        timestampBuffer.addAll(
            event.samples.map((item) => DartTimestamp(item.timeStamp.toUtc())));

        if (buffer.length >= batchSize) {
          worker?.pushChunkWithTimestamp(name, buffer, timestampBuffer);
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[deviceId] = (subscription, StreamType.polar);
  }

  void addMuseStream(String deviceId) async {
    List<List<double>> buffer = [];
    List<Timestamp> timestampBuffer = [];

    await _museSdkPlugin.connect(_muses.indexOf(deviceId));

    final name = deviceId;

    final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
        name, "PPG", Double64ChannelFormat(),
        channelCount: 3, nominalSRate: 64, sourceId: deviceId);

    final result = await worker?.addStream(streamInfo);

    if (result == null || !result) {
      return;
    }

    final subscription = _museSdkPlugin.getPpgStream().listen(
      (event) {
        if (event == null) return;

        buffer.addAll(event.map((item) => item.$2));
        timestampBuffer.addAll(event.map((item) => DartTimestamp(item.$1)));

        if (buffer.length >= batchSize) {
          worker?.pushChunkWithTimestamp(name, buffer, timestampBuffer);
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[deviceId] = (subscription, StreamType.muse);
  }

  void stopStreams() {
    service.stop();

    for (var stream in streams.entries) {
      stream.value.$1.cancel();
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
}
