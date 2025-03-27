part of '../main.dart';

final polar = Polar();

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedOption = 'Polar';
  final List<String> options = ['Polar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find device')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedOption,
              onChanged: (value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
              items: options.map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
            ),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter device id'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final deviceId = _controller.text;
                try {
                  await polar.connectToDevice(deviceId);
                  if (context.mounted) {
                    Provider.of<AppState>(context, listen: false)
                        .addDevice(deviceId);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print("$e");
                }
              },
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}
