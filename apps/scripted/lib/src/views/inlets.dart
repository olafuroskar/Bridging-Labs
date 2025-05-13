part of '../../main.dart';

class InletScreen extends StatelessWidget {
  const InletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<InletProvider>(context);

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
                  MaterialPageRoute(builder: (_) => const InletResultScreen()),
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
        children: appState.handles.entries.map((handle) {
          final selected = appState.selectedInlets.contains(handle.value.$1.id);
          return CheckboxListTile(
            value: selected,
            title: Text(handle.value.$1.info.name),
            subtitle: Text("Threshold: ${handle.value.$2}"),
            onChanged: (val) async {
              double? threshold;
              if (val != null && val) {
                threshold = await showInputDialog(context);
              }
              appState.toggleInletSelection(handle.value.$1.id, threshold);
            },
          );
        }).toList(),
      ),
    );
  }
}
