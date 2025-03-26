import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part 'src/home.dart';
part 'src/outlets.dart';
part 'src/inlets.dart';
part 'src/create_outlet.dart';
part 'src/inlet_results.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const MyApp(),
    ),
  );
}

class AppState extends ChangeNotifier {
  List<String> outlets = [];
  List<String> inlets = ['Inlet A', 'Inlet B', 'Inlet C'];
  List<String> selectedInlets = [];

  void addOutlet(String outlet) {
    outlets.add(outlet);
    notifyListeners();
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
