part of '../../main.dart';

enum StreamType {
  device,
  polar;
}

const batchSize = 20;

class OutletProvider extends ChangeNotifier {
  List<(String, StreamType)> devices = [];
  String? selectedDevice;
  Map<String, (StreamSubscription<Object?>, StreamType)> streams = {};
  bool isWorkerListenedTo = false;

  // final worker = Worker();
  OutletWorker? worker;

  Future<void> findDevices() async {
    if (Platform.isIOS || Platform.isAndroid) {
      devices = [
        ('Gyroscope', StreamType.device),
        ("Accelerometer", StreamType.device)
      ];
    }

    polar.searchForDevice().listen((event) {
      if (!devices.any((item) => item.$1 == event.deviceId)) {
        devices.add((event.deviceId, StreamType.polar));
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<void> addStream(String deviceId) async {
    print("trying to add stream");

    worker ??= await OutletWorker.spawn();

    print("after spawn");

    if (deviceId == "Gyroscope") {
      addGyroscopeStream(deviceId);
    } else if (deviceId == "Accelerometer") {
      addAccelerometerStream(deviceId);
    } else {
      addPolarStream(deviceId);
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
    List<double> timestampBuffer = [];

    final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
        deviceId, "Accelerometer", Double64ChannelFormat(),
        channelCount: 3,
        nominalSRate: intervalToFrequency(SensorInterval.normalInterval),
        sourceId: deviceId);

    final result = await worker?.addStream(streamInfo);

    if (result == null || !result) {
      return;
    }

    final subscription = userAccelerometerEventStream(
            samplingPeriod: SensorInterval.normalInterval)
        .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        timestampBuffer.add(event.timestamp.millisecondsSinceEpoch / 1000);

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
    List<double> timestampBuffer = [];

    polar.connectToDevice(deviceId);

    print("Connected");

    try {
      await polar.sdkFeatureReady.firstWhere((e) =>
          e.identifier == deviceId &&
          e.feature == PolarSdkFeature.onlineStreaming);
    } catch (e) {
      print("$e");
    }
    print("features");

    final streamInfo = StreamInfoFactory.createIntStreamInfo(
        "Polar $deviceId", "PPG", Int64ChannelFormat(),
        channelCount: 4, nominalSRate: 135, sourceId: deviceId);

    print("Trying to add stream");

    final result = await worker?.addStream(streamInfo);

    print(result);

    if (result == null || !result) {
      return;
    }

    final subscription = polar.startPpgStreaming(deviceId).listen(
      (event) {
        buffer.addAll(event.samples.map((item) => item.channelSamples));
        timestampBuffer.addAll(event.samples
            .map((item) => item.timeStamp.millisecondsSinceEpoch / 1000));

        if (buffer.length >= batchSize) {
          worker?.pushChunkWithTimestamp(deviceId, buffer, timestampBuffer);
          buffer.clear();
          timestampBuffer.clear();
        }
      },
    );

    streams[deviceId] = (subscription, StreamType.polar);
  }

  void stopStreams() {
    for (var stream in streams.entries) {
      stream.value.$1.cancel();
      if (stream.value.$2 == StreamType.polar) {
        polar.disconnectFromDevice(stream.key);
      }
    }
    worker?.close();
    worker = null;
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }
}
