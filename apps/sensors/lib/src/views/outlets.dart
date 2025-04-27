part of '../../main.dart';

class OutletScreen extends StatefulWidget {
  const OutletScreen({super.key});

  @override
  State<OutletScreen> createState() => _OutletScreenState();
}

final polar = Polar();

class _OutletScreenState extends State<OutletScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    polar.batteryLevel.listen((e) => developer.log('Battery: ${e.level}'));
    polar.deviceConnecting.listen((_) => developer.log('Device connecting'));
    polar.deviceConnected.listen((_) => developer.log('Device connected'));
    polar.deviceDisconnected
        .listen((_) => developer.log('Device disconnected'));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OutletProvider>(builder: (_, appState, __) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Sources'),
            actions: [
              IconButton(
                  onPressed: () async {
                    await appState.findDevices();
                  },
                  icon: const Icon(Icons.refresh)),
              IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => OutletFormScreen(
                                defaultConfig:
                                    getConfig("Marker", StreamType.marker),
                              ))),
                  icon: const Icon(Icons.add)),
            ],
          ),
          body: AvailableDevices());
    });
  }
}
