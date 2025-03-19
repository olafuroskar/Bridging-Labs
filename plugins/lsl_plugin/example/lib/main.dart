import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:lsl_plugin/lsl_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // late int sumResult;
  // late Future<int> sumAsyncResult;
  OutletManager<double>? outletManager;
  String? error;

  @override
  void initState() {
    super.initState();

    // sumResult = lsl_plugin.sum(1, 2);
    // sumAsyncResult = lsl_plugin.sumAsync(3, 4);
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'This calls a native function through FFI that is shipped as source in the package. '
                  'The native code is built as part of the Flutter Runner build.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                TextButton(
                    onPressed: () {
                      final streamInfo =
                          StreamInfoFactory.createDoubleStreamInfo(
                              "Test", "EEG", Double64ChannelFormat());

                      dev.log("creating outlet");
                      setState(() {
                        final manager = OutletManager(streamInfo);
                        final result = manager.create();
                        switch (result) {
                          case Error(error: var e):
                            error = e.toString();
                            break;
                          default:
                            outletManager = manager;
                        }
                      });
                    },
                    child: Text("Create outlet")),
                TextButton(
                    onPressed: () {
                      final result = outletManager
                          ?.pushSample([Random().nextDouble() * 100]);

                      switch (result) {
                        case Error(error: var e):
                          error = e.toString();
                          break;
                        default:
                      }
                    },
                    child: Text("Push sample")),
                spacerSmall,
                TextButton(
                    onPressed: () {
                      dev.log("destroying outlet");
                      setState(() {
                        outletManager?.destroy();
                      });
                    },
                    child: Text("Destroy outlet")),
                spacerSmall,
                Text(error == null ? "No error" : error!)
                // TextButton(
                //     onPressed: () {
                //       var inlet = test_ffi.Inlet();
                //       setState(() {
                //         numStreams = inlet.getNumStreams();
                //       });
                //     },
                //     child: Text("Find streams")),
                // spacerSmall,
                // Text("NumStreams: $numStreams"),
                // spacerSmall,
                // Text(
                //   outlet == null ? "Outlet is null" : outlet!.getStreamXml(),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
