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
          )
        ],
      ),
      body: ListView(
        children: appState.streams.map((inlet) {
          final selected = appState.selectedInlets.contains(inlet.info.name);
          return CheckboxListTile(
            value: selected,
            title: Text(inlet.info.name),
            onChanged: (_) => appState.toggleInletSelection(inlet.info.name),
          );
        }).toList(),
      ),
    );
  }
}
