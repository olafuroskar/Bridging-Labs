part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;

  Map<String, (ResolvedStreamHandle handle, double threshold)> handles = {};

  Map<String, Sample<double>> latestSamples = {};

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  final Map<String, StreamSubscription<Sample<Object?>>?> inlets = {};

  List<String> get streams =>
      handles.values.map((handle) => handle.$1.info.name).toList();

  InletWorker? worker;

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
  }

  void createInlet() async {
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
          latestSamples[inlet] = sample;
        });
      }
    }

    notifyListeners();
  }
}
