part of '../../main.dart';

enum StreamType { random, sine, marker }

const batchSize = 20;

typedef Device = (String name, StreamType streamType, bool active);

class OutletProvider extends ChangeNotifier {
  Map<String, Device> devices = {};

  String? selectedDevice;
  Map<String, (StreamSubscription<Object?>?, StreamType)> streams = {};
  bool isWorkerListenedTo = false;
  OutletWorker? worker;

  Future<void> addStream(OutletConfigDto config) async {
    worker ??= await OutletWorker.spawn();

    switch (config.streamType) {
      case StreamType.random:
        addRandomStream(config);
      case StreamType.sine:
        addSineWaveStream(config);
      case StreamType.marker:
        addMarkerStream(config);
    }

    _activate(config);
    notifyListeners();
  }

  /// Creates and subscribes to a sine wave data stream
  void addRandomStream(OutletConfigDto config) async {
    final result = await worker?.addStream(
        _createDoubleStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final random = RandomStream(
        samplingRate: config.nominalSRate, amplitude: config.amplitude);

    final subscription = random.stream.listen(
      (datum) {
        List<double> sample = [datum];
        worker?.pushSample(config.name, sample);
      },
    );

    streams[config.name] = (subscription, StreamType.random);
  }

  /// Creates and subscribes to a sine wave data stream
  void addSineWaveStream(OutletConfigDto config) async {
    final result = await worker?.addStream(
        _createDoubleStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    final sineWave = SineWaveStream(
        samplingRate: config.nominalSRate,
        amplitude: config.amplitude,
        wavelength: config.wavelength);

    final subscription = sineWave.stream.listen(
      (datum) {
        List<double> sample = [datum];
        worker?.pushSample(config.name, sample);
      },
    );

    streams[config.name] = (subscription, StreamType.sine);
  }

  void addMarkerStream(OutletConfigDto config) async {
    final result = await worker?.addStream(
        _createStringStreamInfo(config), _getConfig(config));

    if (result == null || !result) {
      return;
    }

    streams[config.name] = (null, StreamType.marker);
  }

  void pushMarkers(String markerName, List<String> markers) async {
    await worker?.pushSample(markerName, markers);
  }

  void stopStream(String name) {
    // Called before stream is removed as markers don't have Dart streams.
    _deactivate(name);

    final stream = streams[name];
    if (stream == null) return;

    stream.$1?.cancel();

    streams.remove(name);
    _deactivate(name);

    if (streams.isEmpty) {
      worker?.close();
      worker = null;
    }

    notifyListeners();
  }

  void stopStreams() {
    for (var stream in streams.entries) {
      stream.value.$1?.cancel();
    }

    worker?.close();
    worker = null;
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }

  OutletConfig _getConfig(OutletConfigDto configDto) {
    return OutletConfig(configDto.chunkSize, configDto.maxBuffered);
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

  StreamInfo<String> _createStringStreamInfo(OutletConfigDto config) {
    return StreamInfoFactory.createStringStreamInfo(
        config.name, config.type, config.channelFormat as ChannelFormat<String>,
        channelCount: config.channelCount,
        nominalSRate: config.nominalSRate,
        sourceId: config.sourceId);
  }
}
