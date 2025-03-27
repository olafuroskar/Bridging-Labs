part of '../main.dart';

class ActiveOutlets extends StatelessWidget {
  const ActiveOutlets({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active outlets'),
        actions: [
          IconButton(
              onPressed: () => appState.stopPolarStreams(),
              icon: const Icon(Icons.clear)),
        ],
      ),
      body: ListView(
        children: appState.polarStreams.map((item) {
          return ListTile(
            title: Text(item.$3),
          );
        }).toList(),
      ),
    );
  }
}
