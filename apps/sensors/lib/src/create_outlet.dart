part of '../main.dart';

class _CreateOutletScreenState extends State<CreateOutletScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedOption = 'Option 1';
  final List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Outlet')),
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
              decoration: const InputDecoration(labelText: 'Enter outlet name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final outlet = '$_selectedOption - ${_controller.text}';
                Provider.of<AppState>(context, listen: false).addOutlet(outlet);
                Navigator.pop(context);
              },
              child: const Text('Create'),
            )
          ],
        ),
      ),
    );
  }
}
