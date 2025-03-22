import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin_example/src/models/inlet_model.dart';
import 'package:lsl_plugin_example/src/models/outlet_model.dart';
import 'package:provider/provider.dart';

part 'src/app.dart';
part 'src/views/inlet_page.dart';
part 'src/views/outlet_page.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => OutletModel(),
    ),
    ChangeNotifierProvider(
      create: (context) => InletModel(),
    )
  ], child: const App()));
}
