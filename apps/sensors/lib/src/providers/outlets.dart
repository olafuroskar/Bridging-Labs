part of '../../main.dart';

class OutletProvider extends ChangeNotifier {
  List<String> devices = [];
  String? selectedDevice;
  List<(StreamSubscription<Object?>, OutletManager<Object?>, String)>
      polarStreams = [];

  Future<void> findDevices() async {
    // devices = ['B69BC32A'];
    polar.searchForDevice().take(5).fold([], (previous, element) {
      return previous + [element.deviceId];
    });
    notifyListeners();
  }

  Future<void> addPolarStream(String deviceId) async {
    OutletManager<int>? outletManager;
    try {
      await polar.sdkFeatureReady.firstWhere((e) => e.identifier == deviceId);

      final streamInfo = StreamInfoFactory.createIntStreamInfo(
          "Polar $deviceId", "ECG", Int64ChannelFormat(), 1, 1);
      outletManager = OutletManager(streamInfo, 1);

      final subscription = polar.startHrStreaming(deviceId).listen((data) {
        final List<List<int>> chunk = [];
        // final List<double> timestamps = [];

        for (var sample in data.samples) {
          chunk.add([sample.hr]);
        }
        outletManager?.pushChunk(chunk);
      });

      polarStreams.add((subscription, outletManager, deviceId));
    } catch (e) {
      outletManager?.destroy();
    }
    notifyListeners();
  }

  void addDevice() {
    final device = selectedDevice;
    if (device == null) return;
    devices.add(device);
    notifyListeners();
  }

  void stopPolarStreams() {
    for (var (sub, outletManager, _) in polarStreams) {
      sub.cancel();
      outletManager.destroy();
    }
    polarStreams.clear();
  }

  void toggleDeviceSelection(String? device) {
    selectedDevice = device;
    notifyListeners();
  }

  void clearDeviceSelection() {
    selectedDevice = null;
    notifyListeners();
  }
}
