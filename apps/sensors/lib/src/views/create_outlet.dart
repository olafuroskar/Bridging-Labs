part of '../../main.dart';

class _CreateOutletScreenState extends State<CreateOutletScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
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
                  return DropdownMenuItem(
                      value: option.$1, child: Text(option.$1));
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
                  await appState.addStream(selectedDevice);

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
                  appState.stopStreams();
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
