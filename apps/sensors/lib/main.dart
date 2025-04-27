import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:muse_sdk/muse_sdk.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polar/polar.dart';
import 'package:provider/provider.dart';
import 'package:sensors/src/models/outlet_config_dto.dart';
import 'package:sensors/src/providers/audio_handler.dart';
import 'package:sensors/src/providers/utils.dart';
import 'package:sensors/src/views/outlet_form.dart';
import 'package:sensors/src/widgets/show_confirmation_dialog.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:share_plus/share_plus.dart';

part 'src/views/home.dart';
part 'src/views/outlets.dart';
part 'src/views/inlets.dart';
part 'src/views/inlet_results.dart';
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
