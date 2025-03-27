import 'dart:async';

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
  List<String> inlets = ['Inlet A', 'Inlet B', 'Inlet C'];
  List<String> selectedInlets = [];
  List<String> selectedDevices = [];

  List<PolarStreamingData<Object?>> subs = [];
  List<(StreamSubscription<Object?>, OutletManager<Object?>, String)>
      polarStreams = [];

  void addPolarStream(String deviceId) {
    final streamInfo = StreamInfoFactory.createIntStreamInfo(
        "Polar $deviceId", "ECG", Int64ChannelFormat());
    final outletManager = OutletManager(streamInfo);

    final subscription = polar.startEcgStreaming(deviceId).listen((data) {
      final List<List<int>> chunk = [];
      final List<double> timestamps = [];

      for (var sample in data.samples) {
        chunk.add([sample.voltage]);
        timestamps.add(sample.timeStamp.millisecondsSinceEpoch / 1000);
      }

      print(chunk);
      outletManager.pushChunkWithTimastamps(chunk, timestamps);
    });

    polarStreams.add((subscription, outletManager, deviceId));
  }

  void addDevice(String device) {
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

  void toggleDeviceSelection(String device) {
    if (selectedDevices.contains(device)) {
      selectedDevices.remove(device);
    } else {
      selectedDevices.add(device);
    }
    notifyListeners();
  }

  void clearDeviceSelection() {
    selectedDevices.clear();
    notifyListeners();
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
