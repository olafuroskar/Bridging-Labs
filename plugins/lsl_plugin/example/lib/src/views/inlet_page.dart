part of '../../main.dart';

class InletPage extends StatefulWidget {
  const InletPage({super.key});

  @override
  State<InletPage> createState() => _InletPageState();
}

class _InletPageState extends State<InletPage> {
  bool loading = false;
  List<ResolvedStreamHandle> streams = [];
  String? error;

  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InletModel>(builder: (context, inletModel, child) {
      final streams = inletModel.streams;

      return MaterialApp(
          home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: TextButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                inletModel.resolveStreams(2);
                setState(() {
                  loading = false;
                });
              },
              child: Text("Get available streams")),
          leading: TextButton(
              onPressed: () {
                inletModel.removeAll();
              },
              child: Text("Destroy inlets")),
        ),
        body: loading
            ? CircularProgressIndicator()
            : ListView.builder(
                itemCount: streams.length,
                itemBuilder: (context, index) {
                  final info = streams[index].info;
                  return ListTile(
                    title: Text(info.name),
                    subtitle: Text(inletModel.exampleSamples.join("+")),
                    leading: !inletModel.hasInlet(info.name)
                        ? IconButton(
                            onPressed: () {
                              inletModel.createInlet(streams[index]);
                            },
                            icon: Icon(Icons.create))
                        : IconButton(
                            onPressed: () {
                              inletModel.pullSample(info.name);
                            },
                            icon: Icon(Icons.delete)),
                  );
                }),
      ));
    });
  }
}
