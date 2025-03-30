part of '../../main.dart';

class InletResultScreen extends StatelessWidget {
  const InletResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InletProvider>(builder: (context, appState, child) {
      return Scaffold(
        appBar: AppBar(title: const Text('Selected Inlets'), actions: [
          IconButton(
              onPressed: () {
                appState.createInlet();
              },
              icon: Icon(Icons.play_arrow))
        ]),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    const Row(
                      children: [Text("Int")],
                    )
                  ] +
                  appState.currentIntChunk
                      .map((item) => Row(
                          children: [Text(item.$2.toString())] +
                              item.$1
                                  .map((elem) => Text(elem.toString()))
                                  .toList()))
                      .toList() +
                  [
                    const Row(
                      children: [Text("Double")],
                    )
                  ] +
                  appState.currentDoubleChunk
                      .map((item) => Row(
                          children: [Text(item.$2.toString())] +
                              item.$1
                                  .map((elem) => Text(elem.toString()))
                                  .toList()))
                      .toList() +
                  [
                    const Row(
                      children: [Text("String")],
                    )
                  ] +
                  appState.currentStringChunk
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
