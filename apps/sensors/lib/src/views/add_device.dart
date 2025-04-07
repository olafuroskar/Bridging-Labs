part of '../../main.dart';

final polar = Polar();

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
        appBar: AppBar(title: const Text('Find device')),
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
            ],
          ),
        ),
      );
    });
  }
}

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}
