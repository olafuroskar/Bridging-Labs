import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:polar/polar.dart';
import 'package:provider/provider.dart';

part 'src/home.dart';
part 'src/outlets.dart';
part 'src/inlets.dart';
part 'src/create_outlet.dart';
part 'src/inlet_results.dart';
part 'src/add_device.dart';
part 'src/available_devices.dart';
part 'src/active_outlets.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  List<String> devices = [];
  String? selectedDevice;
  List<(List<int>, double)> currentChunk = [];

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  List<ResolvedStreamHandle<int>> streams = [];
  final Map<String, InletManager<int>> _inlets = {};

  List<PolarStreamingData<Object?>> subs = [];
  List<(StreamSubscription<Object?>, OutletManager<Object?>, String)>
      polarStreams = [];

  Future<void> findDevices() async {
    devices = ['B69BC32A'];
    // polar.searchForDevice().take(1).fold([], (previous, element) {
    //   return previous + [element.deviceId];
    // });
    notifyListeners();
  }

  Future<void> addPolarStream(String deviceId) async {
    OutletManager<int>? outletManager;
    try {
      await polar.sdkFeatureReady.firstWhere((e) => e.identifier == deviceId);

      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Polar $deviceId", "ECG", Int64ChannelFormat(), 1, 1);
      outletManager = OutletManager(streamInfo, 1);

      final subscription = polar.startHrStreaming(deviceId).listen((data) {
        final List<List<int>> chunk = [];
        // final List<double> timestamps = [];

        for (var sample in data.samples) {
          chunk.add([sample.hr]);
        }
        outletManager?.pushChunk(chunk);
      });

      polarStreams.add((subscription, outletManager, deviceId));
    } catch (e) {
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

  void stopPolarStreams() {
    for (var (sub, outletManager, _) in polarStreams) {
      sub.cancel();
      outletManager.destroy();
    }
    polarStreams.clear();
  }

  void toggleInletSelection(String inlet) {
    if (selectedInlets.contains(inlet)) {
      selectedInlets.remove(inlet);
    } else {
      selectedInlets.add(inlet);
    }
    notifyListeners();
  }

  void clearInletSelection() {
    selectedInlets.clear();
    notifyListeners();
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }

  void clearInlets() {
    for (var inlet in _inlets.values) {
      inlet.closeStream();
    }
    _inlets.clear();
  }

  void clearDeviceSelection() {
    selectedDevice = null;
    notifyListeners();
  }

  Future<void> resolveStreams(double waitTime) async {
    await streamManager.resolveStreams(waitTime);
    streams = streamManager.getIntStreamHandles();

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void createInlet() {
    // This should perhaps be an id instead
    final handle = streams[0];
    final key = handle.info.name;

    // Inlet has already been created for this stream
    if (_inlets.containsKey(key)) return;
    final inletManager = streamManager.createInlet<int>(handle);
    _inlets[key] = inletManager;

    notifyListeners();
  }

  void listenToInlet() async {
    final handle = streams[0];
    final name = handle.info.name;

    final inlet = _inlets[name];

    if (inlet == null) return;

    await inlet.openStream();
    inlet.startChunkStream().listen((chunk) {
      currentChunk = chunk;
      notifyListeners();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inlet/Outlet App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
