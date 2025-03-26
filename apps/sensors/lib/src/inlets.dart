part of '../main.dart';

class InletScreen extends StatelessWidget {
  const InletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

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
          )
        ],
      ),
      body: ListView(
        children: appState.inlets.map((inlet) {
          final selected = appState.selectedInlets.contains(inlet);
          return CheckboxListTile(
            value: selected,
            title: Text(inlet),
            onChanged: (_) => appState.toggleInletSelection(inlet),
          );
        }).toList(),
      ),
    );
  }
}
