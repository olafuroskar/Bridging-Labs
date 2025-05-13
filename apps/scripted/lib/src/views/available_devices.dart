part of '../../main.dart';

class AvailableDevices extends StatelessWidget {
  const AvailableDevices({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<OutletProvider>(context);

    return Scaffold(
      body: appState.devices.isEmpty
          ? Container(
              margin: EdgeInsets.all(16),
              child: Text("No available sources"),
            )
          : ListView(
              children: appState.devices.values.map((device) {
                return ListTile(
                  title: Text(device.$1),
                  trailing: device.$3
                      ? IconButton(
                          onPressed: () async {
                            final confirmed =
                                await showConfirmationDialog(context);
                            if (confirmed ?? false) {
                              appState.stopStream(device.$1);
                            }
                          },
                          icon: Icon(Icons.stop, color: Colors.red))
                      : IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OutletFormScreen(
                                        defaultConfig:
                                            getConfig(device.$1, device.$2),
                                      ))),
                          icon: Icon(Icons.wifi_tethering)),
                );
              }).toList(),
            ),
    );
  }
}
