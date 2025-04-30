part of '../../main.dart';

class MarkerScreen extends StatefulWidget {
  const MarkerScreen({super.key});

  @override
  State<MarkerScreen> createState() => _MarkerScreenState();
}

class _MarkerScreenState extends State<MarkerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<String> _buttons = [];

  void _addButton() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _buttons.add(text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Marker stream'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._buttons.map((text) => Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
                    child: ElevatedButton(
                      onPressed: () {
                        appState.pushMarkers([text]);
                      },
                      style: ButtonStyle(
                          fixedSize:
                              WidgetStatePropertyAll(Size.fromHeight(64))),
                      child: Text(text, style: TextStyle(fontSize: 24)),
                    ),
                  )),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Enter text',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addButton,
                    child: const Text('Okay'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
