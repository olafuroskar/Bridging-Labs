import 'dart:developer';

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
  OutletService<int>? outletService;
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
                      final streamInfoService = StreamInfoService();
                      final streamInfo = streamInfoService.createIntStreamInfo(
                          "Test", "EEG", Int32ChannelFormat());

                      log("creating outlet");
                      setState(() {
                        final service = OutletService(streamInfo);
                        final result = service.create();
                        switch (result) {
                          case Error(error: var e):
                            error = e.toString();
                            break;
                          default:
                            outletService = service;
                        }
                      });
                    },
                    child: Text("Create outlet")),
                spacerSmall,
                TextButton(
                    onPressed: () {
                      log("destroying outlet");
                      setState(() {
                        outletService?.destroy();
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
