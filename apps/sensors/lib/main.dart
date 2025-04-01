import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:polar/polar.dart';
import 'package:provider/provider.dart';
import 'package:sensors/src/providers/worker2.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'src/views/home.dart';
part 'src/views/outlets.dart';
part 'src/views/inlets.dart';
part 'src/views/create_outlet.dart';
part 'src/views/inlet_results.dart';
part 'src/views/add_device.dart';
part 'src/views/available_devices.dart';
part 'src/views/active_outlets.dart';

part 'src/providers/outlets.dart';
part 'src/providers/inlets.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => OutletProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => InletProvider(),
      ),
    ],
    child: MyApp(),
  ));
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
