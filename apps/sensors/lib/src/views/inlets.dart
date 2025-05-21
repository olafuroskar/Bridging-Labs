part of '../../main.dart';

class InletScreen extends StatelessWidget {
  const InletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InletProvider>(builder: (context, appState, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inlets'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (appState.selectedInlets.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const InletResultScreen()),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                appState.resolveStreams(2);
              },
            ),
            IconButton(
              onPressed: () async {
                appState.clearInlets();
              },
              icon: const Icon(Icons.delete),
            ),
            Checkbox(
                value: appState.synchronize,
                onChanged: (val) => appState.setSynchronization(val))
          ],
        ),
        body: ListView(
          children: appState.handles.map((handle) {
            final selected = appState.selectedInlets.contains(handle.id);
            return CheckboxListTile(
              value: selected,
              title: Text(
                  "${handle.info.name}: ${appState.writtenLines[handle.id]}"),
              onChanged: (_) => appState.toggleInletSelection(handle.id),
            );
          }).toList(),
        ),
      );
    });
  }
}
