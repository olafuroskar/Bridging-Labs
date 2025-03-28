part of '../main.dart';

class AvailableDevices extends StatelessWidget {
  const AvailableDevices({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available devices'),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDeviceScreen()),
                  ),
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateOutletScreen()),
                  ),
              icon: const Icon(Icons.play_arrow)),
        ],
      ),
      body: ListView(
        children: appState.devices.map((device) {
          final selected = appState.selectedDevice == device;
          return CheckboxListTile(
            value: selected,
            title: Text(device),
            onChanged: (_) => appState.toggleDeviceSelection(device),
          );
        }).toList(),
      ),
    );
  }
}
