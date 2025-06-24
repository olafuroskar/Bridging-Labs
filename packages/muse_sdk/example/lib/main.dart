import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:muse_sdk/muse_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  List<String> _muses = [];
  final _museSdkPlugin = MuseSdk();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void listenToMuse() {
    _museSdkPlugin.getConnectionStream().listen((event) {
      if (event == null) return;
      List<String> muses = List<String>.from(event);
      setState(() {
        _muses = muses;
      });
      print('Muses in Dart: $muses');
    });

    _museSdkPlugin.getPpgStream().listen((event) {
      if (event == null) return;
      // final timestamp = event.$1;
      print('🍂 ${event.length}');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _museSdkPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Column(
                children: [
                      Center(
                        child: Text('Running on: $_platformVersion\n'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final granted = (await Permission.bluetoothScan
                                  .request()
                                  .isGranted) &&
                              (await Permission.bluetoothConnect
                                  .request()
                                  .isGranted);
                          print(granted);
                        },
                        child: const Text('Init bluetooth'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          listenToMuse();
                          _museSdkPlugin.initialize();
                        },
                        child: const Text('Init'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _museSdkPlugin.isBluetoothEnabled();
                        },
                        child: const Text('Check bt'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _museSdkPlugin.refreshMuseList();
                        },
                        child: const Text('refresh'),
                      )
                    ] +
                    _muses
                        .map((muse) => TextButton(
                            onPressed: () =>
                                _museSdkPlugin.connect(_muses.indexOf(muse)),
                            child: Text(muse)))
                        .toList() +
                    [
                      ElevatedButton(
                          onPressed: () => _museSdkPlugin.disconnect(),
                          child: const Text("Disconnect Muse"))
                    ])));
  }
}
