part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;

  Map<String, (ResolvedStreamHandle handle, double threshold)> handles = {};

  String? firstInlet;
  Map<String, List<Sample<double>>> sampleBuffer = {};
  final markerStreamName = "Trigger markers";
  final OutletProvider outletProvider;

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

  void criteriaMet(List<Sample<double>> samples) {
    outletProvider.pushMarkers(markerStreamName, ["Thresholds"]);
  }

  void createInlet() async {
    if (!outletProvider.streams.containsKey(markerStreamName)) {
      outletProvider.addStream(getConfig(markerStreamName, StreamType.marker));
    }

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

          if (firstInlet == inlet) {
            bool areAllUnderThreshold = true;
            final List<Sample<double>> samples = [sample];

            final firstThreshold = handles[inlet]?.$2;

            /// If first inlet's threshold value doesn't exist or is above threshold, the criteria will not be met
            if (firstThreshold == null || sample.$1[0] > firstThreshold) {
              areAllUnderThreshold = false;
            }

            /// Iterate through each other selected inlet
            for (final key in selectedInlets.where((k) => k != firstInlet)) {
              /// Early return if the first one already did not meet the criteria
              if (!areAllUnderThreshold) continue;

              final buffer = sampleBuffer[key];

              /// If the buffer doesn't exist or is empty the criteria can not be met
              if (buffer == null || buffer.isEmpty) {
                areAllUnderThreshold = false;
                continue;
              }

              /// Find the matching sample based on the timestamp within a tolerance
              final (matchingSample, index) =
                  findMathcingSample(buffer, sample.$2);
              if (matchingSample == null) {
                areAllUnderThreshold = false;
                continue;
              }
              samples.add(matchingSample);

              final threshold = handles[key]?.$2;

              /// If the inlet's threshold value doesn't exist or is above threshold, the criteria will not be met
              if (threshold == null || matchingSample.$1[0] > threshold) {
                areAllUnderThreshold = false;
              } else {
                /// If it does then we remove the matching sample from the buffer so it will not be doubly counted.
                buffer.removeAt(index);
                sampleBuffer[key] = buffer;
              }
            }

            if (areAllUnderThreshold) criteriaMet(samples);
          } else {
            /// The period in seconds that a buffer should be maintained
            final bufferPeriodInSeconds = 2;

            if (!sampleBuffer.containsKey(inlet)) {
              /// Initialise the given buffer
              sampleBuffer[inlet] = [sample];
            } else {
              final buffer = sampleBuffer[inlet];
              if (buffer != null) {
                final firstBufferSample = buffer.isEmpty ? null : buffer.first;

                if (firstBufferSample != null &&
                    firstBufferSample.$2 + bufferPeriodInSeconds < sample.$2) {
                  /// Restart the buffer once period has been exceded
                  sampleBuffer[inlet] = [sample];
                } else {
                  /// Otherwise add the latest sample to the buffer
                  sampleBuffer[inlet]?.add(sample);
                }
              }
            }
          }
        });
      }

      firstInlet ??= inlet;
    }

    notifyListeners();
  }
}
