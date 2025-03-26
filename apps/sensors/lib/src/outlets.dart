part of '../main.dart';

class OutletScreen extends StatelessWidget {
  const OutletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Outlets')),
      body: ListView(
        children: appState.outlets
            .map((outlet) => ListTile(title: Text(outlet)))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateOutletScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateOutletScreen extends StatefulWidget {
  const CreateOutletScreen({super.key});

  @override
  State<CreateOutletScreen> createState() => _CreateOutletScreenState();
}
