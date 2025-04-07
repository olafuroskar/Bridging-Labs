part of '../../main.dart';

class ActiveOutlets extends StatelessWidget {
  const ActiveOutlets({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<OutletProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active outlets'),
        actions: [
          IconButton(
              onPressed: () => appState.stopStreams(),
              icon: const Icon(Icons.clear)),
        ],
      ),
      body: ListView(
        children: appState.streams.keys.map((item) {
          return ListTile(
            title: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
