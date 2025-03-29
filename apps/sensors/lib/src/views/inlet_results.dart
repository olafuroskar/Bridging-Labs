part of '../../main.dart';

class InletResultScreen extends StatelessWidget {
  const InletResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appState, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('Selected Inlets'), actions: [
          IconButton(
              onPressed: () {
                appState.createInlet();
                appState.listenToInlet();
              },
              icon: Icon(Icons.play_arrow))
        ]),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: appState.currentChunk
                  .map((item) => Row(
                      children: [Text(item.$2.toString())] +
                          item.$1
                              .map((elem) => Text(elem.toString()))
                              .toList()))
                  .toList()),
        ),
      );
    });
  }
}
