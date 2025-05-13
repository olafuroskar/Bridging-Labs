import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scripted/src/models/outlet_config_dto.dart';
import 'package:scripted/src/providers/random_stream.dart';
import 'package:scripted/src/providers/sine_wave_stream.dart';
import 'package:scripted/src/providers/utils.dart';
import 'package:scripted/src/views/outlet_form.dart';
import 'package:scripted/src/widgets/input_dialog.dart';
import 'package:scripted/src/widgets/show_confirmation_dialog.dart';

part 'src/views/outlets.dart';
part 'src/views/available_devices.dart';
part 'src/views/inlets.dart';
part 'src/views/inlet_results.dart';
part 'src/views/home.dart';

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
