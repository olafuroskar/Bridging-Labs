part of '../../main.dart';

class MarkerScreen extends StatefulWidget {
  const MarkerScreen({super.key});

  @override
  State<MarkerScreen> createState() => _MarkerScreenState();
}

class _MarkerScreenState extends State<MarkerScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Marker stream'),
          actions: [
            IconButton(
                onPressed: () async {
                  final emos = ["1", "2", "3", "4", "5", "END"];
                  for (final emo in emos) {
                    appState.addButton(emo);
                  }
                },
                icon: const Icon(Icons.touch_app)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...appState.markerButtons.map((text) => Padding(
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
              // ...appState.markerButtons.map((text) => Padding(
              //       padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
              //       child: GestureDetector(
              //         onTapDown: (e) {
              //           appState.pushMarkers([text]);
              //         },
              //         child: ElevatedButton(
              //           onPressed: () {},
              //           style: ButtonStyle(
              //               fixedSize:
              //                   WidgetStatePropertyAll(Size.fromHeight(64))),
              //           child: Text(text, style: TextStyle(fontSize: 24)),
              //         ),
              //       ),
              //     )),
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
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        appState.addButton(text);
                        setState(() {
                          _controller.clear();
                        });
                      }
                    },
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
