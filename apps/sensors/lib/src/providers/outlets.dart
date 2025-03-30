part of '../../main.dart';

enum StreamType {
  device,
  polar;
}

class OutletProvider extends ChangeNotifier {
  List<String> devices = [];
  String? selectedDevice;
  Map<String, (StreamSubscription<Object?>, OutletManager<Object?>, StreamType)>
      streams = {};

  Future<void> findDevices() async {
    if (Platform.isIOS || Platform.isAndroid) {
      devices = ['Gyroscope', "Accelerometer"];
    }

    final polarDevices = await polar
        .searchForDevice()
        .take(1)
        .timeout(Duration(seconds: 5), onTimeout: (_) => [])
        .map((element) => element.deviceId)
        .toList();

    devices += polarDevices;

    notifyListeners();
  }

  Future<void> addGyroscopeStream() async {
    OutletManager<double>? outletManager;

    try {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Gyroscope mobile",
          "Gyroscope",
          Double64ChannelFormat(),
          3,
          SensorInterval.normalInterval.inSeconds.toDouble());
      outletManager = OutletManager(streamInfo);

      final subscription =
          gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
              .listen(
        (event) {
          outletManager?.pushSample([event.x, event.y, event.z]);
        },
      );

      streams["Gyroscope"] = (subscription, outletManager, StreamType.device);
    } catch (e) {
      print("Stream creation failed: $e");
    }
  }

  Future<void> addUserAccelerometer() async {
    OutletManager<double>? outletManager;

    try {
      final streamInfo = StreamInfoFactory.createDoubleStreamInfo(
          "Accelerometer mobile",
          "Accelerometer",
          Double64ChannelFormat(),
          3,
          SensorInterval.normalInterval.inSeconds.toDouble());
      outletManager = OutletManager(streamInfo);

      final subscription = userAccelerometerEventStream(
              samplingPeriod: SensorInterval.normalInterval)
          .listen(
        (event) {
          outletManager?.pushSample([event.x, event.y, event.z]);
        },
      );

      streams["Accelerometer"] =
          (subscription, outletManager, StreamType.device);
    } catch (e) {
      print("Stream creation failed: $e");
    }
  }

  Future<void> addStream(String deviceId) async {
    if (deviceId == "Gyroscope") {
      return addGyroscopeStream();
    } else if (deviceId == "Accelerometer") {
      return addUserAccelerometer();
    } else {
      return addPolarStream(deviceId);
    }
  }

  Future<void> addPolarStream(String deviceId) async {
    OutletManager<int>? outletManager;
    try {
      polar.connectToDevice(deviceId);
      await polar.sdkFeatureReady.firstWhere((e) =>
          e.identifier == deviceId &&
          e.feature == PolarSdkFeature.onlineStreaming);

      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Polar $deviceId", "PPG", Int64ChannelFormat(), 50);
      outletManager = OutletManager(streamInfo, 1);

      final subscription = polar.startPpgStreaming(deviceId).listen((data) {
        final List<List<int>> chunk = [];
        // final List<double> timestamps = [];

        for (var sample in data.samples) {
          chunk.add(sample.channelSamples);
        }
        print(chunk.length);
        outletManager?.pushChunk(chunk);
      });

      streams[deviceId] = (subscription, outletManager, StreamType.polar);
    } catch (e) {
      print("$e");
      outletManager?.destroy();
    }
    notifyListeners();
  }

  void addDevice() {
    final device = selectedDevice;
    if (device == null) return;
    devices.add(device);
    notifyListeners();
  }

  void stopStreams() {
    stopGyroscope();
    stopAccelerometer();
    stopPolarStreams();
  }

  void stopGyroscope() {
    final gyroStream = streams.remove("Gyroscope");
    if (gyroStream != null) {
      gyroStream.$1.cancel();
      gyroStream.$2.destroy();
    }
  }

  void stopAccelerometer() {
    final gyroStream = streams.remove("Accelerometer");
    if (gyroStream != null) {
      gyroStream.$1.cancel();
      gyroStream.$2.destroy();
    }
  }

  void stopPolarStreams() async {
    for (var entry in streams.entries) {
      await polar.disconnectFromDevice(entry.key);
      entry.value.$1.cancel();
      entry.value.$2.destroy();
    }
    streams.clear();
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }

  void clearDeviceSelection() {
    selectedDevice = null;
    notifyListeners();
  }
}
