part of '../../main.dart';

class OutletPage extends StatefulWidget {
  const OutletPage({super.key});

  @override
  State<OutletPage> createState() => _OutletPageState();
}

class _OutletPageState extends State<OutletPage> {
  String? error;
  final textController =
      TextEditingController.fromValue(TextEditingValue(text: "Testing"));

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const spacerSmall = SizedBox(height: 10);

    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text(''),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child:
                Consumer<OutletModel>(builder: (context, outletModel, child) {
              return Column(
                children: [
                  TextField(controller: textController),
                  TextButton(
                      onPressed: () {
                        final streamInfo =
                            StreamInfoFactory.createDoubleStreamInfo(
                                textController.text,
                                "EEG",
                                Double64ChannelFormat());

                        final manager = OutletManager(streamInfo);
                        final result = manager.create();
                        dev.log("creating outlet");
                        switch (result) {
                          case Error(error: var e):
                            error = e.toString();
                            break;
                          default:
                            outletModel.add(manager);
                        }
                      },
                      child: Text("Create outlet")),
                  // TextButton(
                  //     onPressed: () {
                  //       final result = outletManager
                  //           ?.pushSample([Random().nextDouble() * 100]);
                  //
                  //       switch (result) {
                  //         case Error(error: var e):
                  //           error = e.toString();
                  //           break;
                  //         default:
                  //       }
                  //     },
                  //     child: Text("Push sample")),
                  // spacerSmall,
                  TextButton(
                      onPressed: () {
                        outletModel.removeAll();
                      },
                      child: Text("Destroy outlet")),
                  spacerSmall,
                  Text(error == null ? "No error" : error!)
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
