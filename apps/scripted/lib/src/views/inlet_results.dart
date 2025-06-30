part of '../../main.dart';

class InletResultScreen extends StatefulWidget {
  const InletResultScreen({super.key});

  @override
  State<InletResultScreen> createState() => _InletResultScreenState();
}

enum InletAction {
  stop,
  shareOffset,
  share;
}

class _InletResultScreenState extends State<InletResultScreen> {
  var baselineX = 0.0;
  var baselineY = 0.0;

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
          body: ListView(
              children: appState.handles.entries.map((entry) {
            return ListTile(
              title: Text(entry.value.$1.info.name),
              trailing: PopupMenuButton<InletAction>(
                onSelected: (InletAction? value) {
                  switch (value) {
                    case InletAction.stop:
                      appState.closeInlet(entry.key);
                      break;
                    default:
                  }
                },
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<InletAction>>[
                  const PopupMenuItem<InletAction>(
                    value: InletAction.stop,
                    child: Text('Stop'),
                  ),
                ],
              ),
            );
          }).toList()));
    });
  }
}
