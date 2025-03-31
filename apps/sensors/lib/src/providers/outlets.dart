part of '../../main.dart';

enum StreamType {
  device,
  polar;
}

const batchSize = 50;

class OutletProvider extends ChangeNotifier {
  List<(String, StreamType)> devices = [];
  String? selectedDevice;
  Map<String, StreamSubscription<Object?>> streams = {};
  bool isWorkerListenedTo = false;

  // final worker = Worker();
  Worker2? worker;

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
    worker ??= await Worker2.spawn();

    final result = await worker?.addDevice(deviceId);

    if (result == null || !result) {
      return;
    }

    if (deviceId == "Gyroscope") {
      addGyroscopeStream(deviceId);
    } else if (deviceId == "Accelerometer") {
      addAccelerometerStream(deviceId);
    } else {
      addPolarStream(deviceId);
    }
  }

  void addGyroscopeStream(String deviceId) {
    List<List<double>> buffer = [];
    Timer? batchTimer;

    final subscription =
        gyroscopeEventStream(samplingPeriod: SensorInterval.normalInterval)
            .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        if (buffer.length >= batchSize) {
          worker?.pushChunk(deviceId, buffer);
          buffer.clear();
          batchTimer?.cancel();
        }

        batchTimer ??= Timer(Duration(seconds: 5), () {
          if (buffer.isNotEmpty) {
            worker?.pushChunk(deviceId, buffer);
            buffer.clear();
          }
        });
      },
    );

    streams[deviceId] = subscription;
  }

  void addAccelerometerStream(String deviceId) {
    List<List<double>> buffer = [];

    final subscription = userAccelerometerEventStream(
            samplingPeriod: SensorInterval.normalInterval)
        .listen(
      (event) {
        buffer.add([event.x, event.y, event.z]);
        // print(buffer.length);

        if (buffer.length >= batchSize) {
          worker?.pushChunk(deviceId, buffer);
          buffer.clear();
        }
      },
    );

    streams[deviceId] = subscription;
  }

  void addPolarStream(String deviceId) async {
    List<List<int>> buffer = [];

    polar.connectToDevice(deviceId);

    await polar.sdkFeatureReady.firstWhere((e) =>
        e.identifier == deviceId &&
        e.feature == PolarSdkFeature.onlineStreaming);

    final subscription = polar.startPpgStreaming(deviceId).listen(
      (event) {
        buffer.addAll(event.samples.map((item) => item.channelSamples));

        if (buffer.length >= batchSize) {
          worker?.pushChunk(deviceId, buffer);
          buffer.clear();
        }
      },
    );

    streams[deviceId] = subscription;
  }

  void stopStreams() {
    for (var stream in streams.values) {
      stream.cancel();
    }
    worker?.close();
    worker = null;
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }
}
