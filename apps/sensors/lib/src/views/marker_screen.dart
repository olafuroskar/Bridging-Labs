part of '../../main.dart';

class MarkerScreen extends StatefulWidget {
  const MarkerScreen({super.key});

  @override
  State<MarkerScreen> createState() => _MarkerScreenState();
}

class _MarkerScreenState extends State<MarkerScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Marker stream'),
          ),
          body: Scaffold(
              body: Container(
            margin: EdgeInsets.all(16),
            child: ElevatedButton(
                onPressed: () => appState.pushMarkers(["Marker"]),
                style: ButtonStyle(
                    fixedSize: WidgetStatePropertyAll(Size.fromWidth(20))),
                child: Text("Send marker")),
          )));
    });
  }
}
