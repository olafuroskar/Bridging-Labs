part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;
  final markerStreamName = "Trigger markers";
  final OutletProvider outletProvider;
  String? firstInlet;
  double lastTimestampFast = 0;
  double bufferLengthInSeconds = 2;

  final Chunk<double> slowBuffer = [];
  final Chunk<double> fastBuffer = [];
  List<String> selectedInlets = [];
  List<String> get streams =>
      handles.values.map((handle) => handle.$1.info.name).toList();

  Map<String, List<Sample<double>>> sampleBuffer = {};
  Map<String, (ResolvedStreamHandle handle, double threshold)> handles = {};
  final Map<String, StreamSubscription<Chunk<Object?>>?> inlets = {};

  StreamSynchronizer? streamSynchronizer;
  InletWorker? worker;
  StreamProcessor? streamProcessor;

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

    final slowThreshold = handles.values
        .firstWhere((value) => value.$1.info.nominalSRate <= 5)
        .$2;
    final fastThreshold =
        handles.values.firstWhere((value) => value.$1.info.nominalSRate > 5).$2;

    streamProcessor ??= await StreamProcessor.spawn();
    StreamProcessor.setThresholds(slowThreshold, fastThreshold, 0.25);

    final subscriber =
        await streamProcessor?.startMarkerStream(onCancel: () {});
    subscriber?.listen((samples) {
      criteriaMet(samples.$2, samples.$1);
    });

    // streamSynchronizer = StreamSynchronizer(
    //   buffers: Map.fromEntries(selectedInlets.map((s) => MapEntry(s, []))),
    //   thresholds: Map.fromEntries(
    //       handles.entries.map((entry) => MapEntry(entry.key, entry.value.$2))),
    //   toleranceInSeconds: 0.1,
    //   onSynchronized: criteriaMet,
    //   isFastSampleStream: Map.fromEntries(handles.entries.map((entry) =>
    //       MapEntry(entry.key, entry.value.$1.info.nominalSRate > 5))),
    //   // slowThreshold: slowThreshold,
    //   // fastThreshold: fastThreshold,
    // );

    for (var inlet in selectedInlets) {
      final opened =
          await worker?.open(inlet, synchronize: synchronize ?? false);

      final handle =
          handles.entries.firstWhere((handle) => handle.value.$1.id == inlet);
      final isSlow = handle.value.$1.info.nominalSRate < 5;

      if (opened ?? false) {
        final sampleStream = await worker
            // Explicit sampling rate
            ?.startChunkStream(inlet, samplingRate: 2, onCancel: () {
          notifyListeners();
        });

        inlets[inlet] = sampleStream?.listen((chunk) {
          if (chunk is! Chunk<double>) return;
          if (isSlow) {
            slowBuffer.addAll(chunk);
          } else {
            fastBuffer.addAll(chunk);
          }

          print("✈️ ${slowBuffer.length} ${fastBuffer.length}");
          if (fastBuffer.isNotEmpty) {
            final fastBufferLastTimestamp = fastBuffer.last.$2;

            if (fastBufferLastTimestamp - lastTimestampFast >
                    bufferLengthInSeconds &&
                slowBuffer.isNotEmpty &&
                slowBuffer.first.$2 + 0.5 < fastBufferLastTimestamp) {
              streamProcessor?.process(slowBuffer, fastBuffer);
              fastBuffer.clear();
              lastTimestampFast = fastBufferLastTimestamp;
            }
          }

          if (slowBuffer.isNotEmpty) {
            if (slowBuffer.last.$2 - slowBuffer.first.$2 > 3) {
              slowBuffer.clear();
            }
          }
          // streamSynchronizer?.addSample(inlet, chunk);
        });
      }

      firstInlet ??= inlet;
    }

    notifyListeners();
  }
}
