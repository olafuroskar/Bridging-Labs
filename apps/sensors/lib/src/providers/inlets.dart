part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  List<Sample<int>> currentIntChunk = [];
  List<Sample<double>> currentDoubleChunk = [];
  List<Sample<String>> currentStringChunk = [];

  List<ResolvedStreamHandle<int>> intStreams = [];
  List<ResolvedStreamHandle<double>> doubleStreams = [];
  List<ResolvedStreamHandle<String>> stringStreams = [];

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  final Map<String, InletManager<Object?>> inlets = {};

  List<String> get streams =>
      intStreams.map((stream) => stream.info.name).toList() +
      doubleStreams.map((stream) => stream.info.name).toList() +
      stringStreams.map((stream) => stream.info.name).toList();

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
    intStreams = streamManager.getIntStreamHandles();
    doubleStreams = streamManager.getDoubleStreamHandles();
    stringStreams = streamManager.getStringStreamHandles();

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void _openInlet<S>(ResolvedStreamHandle<S> stream,
      void Function(Chunk<S> chunk) onData) async {
    final key = stream.info.name;

    // Inlet has already been created for this stream
    if (inlets.containsKey(key)) return;

    final inletManager = streamManager.createInlet(stream);

    // Open the stream
    await inletManager.openStream();

    // Start streaming chunks from the stream
    inletManager.startChunkStream().listen(onData);

    inlets[key] = inletManager;
  }

  void createInlet() async {
    for (var stream in intStreams) {
      _openInlet<int>(stream, (chunk) {
        // TODO: Write data to a csv
        currentIntChunk = chunk;
        notifyListeners();
      });
    }

    for (var stream in doubleStreams) {
      _openInlet<double>(stream, (chunk) {
        print(chunk);
        currentDoubleChunk = chunk;
        notifyListeners();
      });
    }

    for (var stream in stringStreams) {
      _openInlet<String>(stream, (chunk) {
        currentStringChunk = chunk;
        notifyListeners();
      });
    }
    notifyListeners();
  }
}
