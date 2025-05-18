part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;

  Map<String, (ResolvedStreamHandle handle, double threshold)> handles = {};

  String? firstInlet;
  Map<String, List<Sample<double>>> sampleBuffer = {};
  final markerStreamName = "Trigger markers";
  final OutletProvider outletProvider;
  StreamSynchronizer? streamSynchronizer;

  List<String> selectedInlets = [];
  final Map<String, StreamSubscription<Sample<Object?>>?> inlets = {};

  List<String> get streams =>
      handles.values.map((handle) => handle.$1.info.name).toList();

  InletWorker? worker;

  InletProvider(this.outletProvider);

  update(OutletProvider outletProvider) {}

  void setSynchronization(bool? val) {
    synchronize = val;
    notifyListeners();
  }

  void toggleInletSelection(String inlet, double? threshold) {
    if (selectedInlets.contains(inlet)) {
      selectedInlets.remove(inlet);
    } else {
      selectedInlets.add(inlet);
      final handle = handles[inlet];
      if (handle != null) {
        handles[inlet] = (handle.$1, threshold ?? 0.0);
      }
    }
    notifyListeners();
  }

  void clearInletSelection() {
    selectedInlets.clear();
    notifyListeners();
  }

  void clearInlets() {
    worker?.shutdown();
    streamSynchronizer = null;
    inlets.clear();
    selectedInlets.clear();
  }

  Future<void> resolveStreams(double waitTime) async {
    worker ??= await InletWorker.spawn();

    final streamHandles = await worker?.resolveStreams() ?? [];

    handles = Map.fromEntries(
        streamHandles.map((handle) => MapEntry(handle.id, (handle, 0.0))));

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void closeInlet(String key) async {
    await inlets[key]?.cancel();
    worker?.stop(key);
    if (firstInlet == key) firstInlet = null;
  }

  void criteriaMet(Sample<double> fast, Sample<double> slow) {
    outletProvider.pushMarkers(
        markerStreamName, ["fast: ${fast.$1[1]}", "slow: ${slow.$1[1]}"]);
  }

  void createInlet() async {
    if (!outletProvider.streams.containsKey(markerStreamName)) {
      outletProvider.addStream(getConfig(markerStreamName, StreamType.marker,
          channelCount: selectedInlets.length));
    }

    // final slowThreshold = handles.values
    //     .firstWhere((value) => value.$1.info.nominalSRate <= 5)
    //     .$2;
    // final fastThreshold =
    //     handles.values.firstWhere((value) => value.$1.info.nominalSRate > 5).$2;

    streamSynchronizer = StreamSynchronizer(
      buffers: Map.fromEntries(selectedInlets.map((s) => MapEntry(s, []))),
      thresholds: Map.fromEntries(
          handles.entries.map((entry) => MapEntry(entry.key, entry.value.$2))),
      toleranceInSeconds: 0.1,
      onSynchronized: criteriaMet,
      isFastSampleStream: Map.fromEntries(handles.entries.map((entry) =>
          MapEntry(entry.key, entry.value.$1.info.nominalSRate > 5))),
      // slowThreshold: slowThreshold,
      // fastThreshold: fastThreshold,
    );

    for (var inlet in selectedInlets) {
      final opened =
          await worker?.open(inlet, synchronize: synchronize ?? false);

      if (opened ?? false) {
        final sampleStream =
            await worker?.startSampleStream(inlet, onCancel: () {
          notifyListeners();
        });

        inlets[inlet] = sampleStream?.listen((sample) {
          if (sample is! Sample<double>) return;
          streamSynchronizer?.addSample(inlet, sample);
        });
      }

      firstInlet ??= inlet;
    }

    notifyListeners();
  }
}
