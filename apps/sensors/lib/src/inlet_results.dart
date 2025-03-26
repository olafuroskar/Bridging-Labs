part of '../main.dart';

class InletResultScreen extends StatelessWidget {
  const InletResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected =
        Provider.of<AppState>(context, listen: false).selectedInlets;

    return Scaffold(
      appBar: AppBar(title: const Text('Selected Inlets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: selected.map((inlet) => Text(inlet)).toList(),
        ),
      ),
    );
  }
}
