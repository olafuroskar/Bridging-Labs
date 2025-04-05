part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;

  Map<String, int> writtenLines = {};

  List<ResolvedStreamHandle<int>> intStreams = [];
  List<ResolvedStreamHandle<double>> doubleStreams = [];
  List<ResolvedStreamHandle<String>> stringStreams = [];

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  final Map<String, (InletManager<Object?>, StreamSubscription<Chunk<Object?>>)>
      inlets = {};

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
      inlet.$2.cancel();
      inlet.$1.closeStream();
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

  void closeInlet(String key) {
    inlets[key]?.$2.cancel();
    inlets[key]?.$1.closeStream();
    inlets.remove(key);
  }

  void shareResult(String key) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$key.csv';
    await Share.shareXFiles([XFile(filePath)]);
  }

  void _openInlet<S>(ResolvedStreamHandle<S> stream,
      void Function(Chunk<S> chunk) onData, void Function() onDone) async {
    final key = stream.info.name;

    // Inlet has already been created for this stream
    if (inlets.containsKey(key)) return;

    final inletManager = streamManager.createInlet(stream);

    // Open the stream
    await inletManager.openStream();

    // Start streaming chunks from the stream
    final listener =
        inletManager.startChunkStream().listen(onData, onDone: onDone);

    inlets[key] = (inletManager, listener);
  }

  void createInlet() async {
    for (var stream in intStreams) {
      final sink = await openCsvFile(stream.id);
      final List<List<dynamic>> buffer = [];
      writtenLines[stream.id] = 0;

      _openInlet<int>(stream, (chunk) {
        buffer.addAll(chunk.map((item) =>
            [item.$2.toString()] + item.$1.map((x) => x.toString()).toList()));

        if (buffer.length > maxBufferSize) {
          writeRow(sink, buffer);
          buffer.clear();
          writtenLines[stream.id] = writtenLines[stream.id]! + maxBufferSize;
          notifyListeners();
        }
      }, () {
        if (buffer.isNotEmpty) {
          writeRow(sink, buffer);
        }
        sink.close();
      });
    }

    for (var stream in doubleStreams) {
      final sink = await openCsvFile(stream.id);
      final List<List<dynamic>> buffer = [];
      writtenLines[stream.id] = 0;

      _openInlet<double>(stream, (chunk) {
        buffer.addAll(chunk.map((item) =>
            [item.$2.toString()] + item.$1.map((x) => x.toString()).toList()));

        if (buffer.length > maxBufferSize) {
          writeRow(sink, buffer);
          buffer.clear();
          writtenLines[stream.id] = writtenLines[stream.id]! + maxBufferSize;
          notifyListeners();
        }
      }, () {
        if (buffer.isNotEmpty) {
          writeRow(sink, buffer);
        }
        sink.close();
      });
    }

    for (var stream in stringStreams) {
      final sink = await openCsvFile(stream.id);
      final List<List<dynamic>> buffer = [];
      writtenLines[stream.id] = 0;

      _openInlet<String>(stream, (chunk) {
        buffer.addAll(chunk.map((item) => [item.$2.toString()] + item.$1));

        if (buffer.length > maxBufferSize) {
          writeRow(sink, buffer);
          buffer.clear();
          writtenLines[stream.id] = writtenLines[stream.id]! + maxBufferSize;
          notifyListeners();
        }
      }, () {
        if (buffer.isNotEmpty) {
          writeRow(sink, buffer);
        }
        sink.close();
      });
    }
    notifyListeners();
  }

  Future<IOSink> openCsvFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName.csv';
    final file = File(filePath);

    return file.openWrite(mode: FileMode.append);
  }

  void writeRow(IOSink sink, List<List<dynamic>> rows) {
    String csvRow = '${const ListToCsvConverter().convert(rows)}\n';
    sink.write(csvRow);
  }
}
