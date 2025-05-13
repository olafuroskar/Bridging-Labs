part of '../../main.dart';

class OutletScreen extends StatefulWidget {
  const OutletScreen({super.key});

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

class _OutletScreenState extends State<OutletScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Sources'),
            actions: [
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OutletFormScreen(
                                defaultConfig:
                                    getConfig("White noise", StreamType.sine),
                              ))),
                  icon: const Icon(Icons.add)),
            ],
          ),
          body: AvailableDevices());
    });
  }
}
