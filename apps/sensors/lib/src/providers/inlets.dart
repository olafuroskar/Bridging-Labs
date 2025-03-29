part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  List<(List<int>, double)> currentChunk = [];
  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  List<ResolvedStreamHandle<int>> streams = [];
  final Map<String, InletManager<int>> inlets = {};

  void toggleInletSelection(String inlet) {
    if (selectedInlets.contains(inlet)) {
      selectedInlets.remove(inlet);
    } else {
      selectedInlets.add(inlet);
    }
    notifyListeners();
  }

  void clearInletSelection() {
    selectedInlets.clear();
    notifyListeners();
  }

  void clearInlets() {
    for (var inlet in inlets.values) {
      inlet.closeStream();
    }
    inlets.clear();
  }

  Future<void> resolveStreams(double waitTime) async {
    await streamManager.resolveStreams(waitTime);
    streams = streamManager.getIntStreamHandles();

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void createInlet() async {
    for (var stream in streams) {
      final key = stream.info.name;

      // Inlet has already been created for this stream
      if (inlets.containsKey(key)) continue;

      final inletManager = streamManager.createInlet<int>(stream);

      // Open the stream
      await inletManager.openStream();

      // Start streaming chunks from the stream
      inletManager.startChunkStream().listen((chunk) {
        // TODO: Write data to a csv
        currentChunk = chunk;
        notifyListeners();
      });

      inlets[key] = inletManager;
    }

    notifyListeners();
  }
}
