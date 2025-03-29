part of '../../main.dart';

class _CreateOutletScreenState extends State<CreateOutletScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (_, appState, __) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Outlet')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton<String>(
                value: appState.selectedDevice,
                onChanged: (value) {
                  appState.toggleDeviceSelection(value);
                },
                items: appState.devices.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await appState.findDevices();
                },
                child: const Text('Discover devices'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDevice = appState.selectedDevice;

                  if (selectedDevice == null) return;
                  await polar.connectToDevice(selectedDevice);
                  await appState.addPolarStream(selectedDevice);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDevice = appState.selectedDevice;
                  if (selectedDevice == null) return;
                  await polar.disconnectFromDevice(selectedDevice);
                  appState.stopPolarStreams();
                },
                child: const Text('disconnect'),
              )
            ],
          ),
        ),
      );
    });
  }
}

class CreateOutletScreen extends StatefulWidget {
  const CreateOutletScreen({super.key});

  @override
  State<CreateOutletScreen> createState() => _CreateOutletScreenState();
}
