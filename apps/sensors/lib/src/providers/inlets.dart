part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;

  Map<String, int> writtenLines = {};

  List<ResolvedStreamHandle<Object?>> handles = [];

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  final Map<String, StreamSubscription<Chunk<Object?>>?> inlets = {};

  List<String> get streams =>
      handles.map((handle) => handle.info.name).toList();

  InletWorker? worker;

  void setSynchronization(bool? val) {
    synchronize = val;
    notifyListeners();
  }

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
    worker?.shutdown();
  }

  Future<void> resolveStreams(double waitTime) async {
    worker ??= await InletWorker.spawn();

    handles = await worker?.resolveStreams() ?? [];

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void closeInlet(String key) async {
    await inlets[key]?.cancel();
    worker?.stop(key);
  }

  void shareResult(String key, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$key.csv';

    List<XFile> files = [XFile(filePath)];

    await Share.shareXFiles(files);
  }

  void createInlet() async {
    for (var inlet in selectedInlets) {
      final handle = handles.firstWhere((handle) => handle.id == inlet);
      final sink = await openCsvFile(inlet);
      writeRow(sink, [
        ['timestamp'] +
            List.generate(handle.info.channelCount, (index) => index.toString())
      ]);

      final offsetSink = await openCsvFile("$inlet-offset");
      writeRow(offsetSink, [
        ["collection_time", "offset"]
      ]);

      final List<List<dynamic>> buffer = [];
      writtenLines[inlet] = 0;

      final opened =
          await worker?.open(inlet, synchronize: synchronize ?? false);

      if (opened ?? false) {
        final chunkStream = await worker?.startChunkStream(inlet, onCancel: () {
          if (buffer.isNotEmpty) {
            writeRow(sink, buffer);
            writtenLines[inlet] = writtenLines[inlet]! + buffer.length;
            buffer.clear();
          }
          sink.close();
        });

        inlets[inlet] = chunkStream?.listen((chunk) {
          buffer.addAll(chunk.map((item) =>
              [item.$2.toString()] +
              item.$1.map((x) => x.toString()).toList()));

          if (buffer.length > maxBufferSize) {
            writeRow(sink, buffer);
            buffer.clear();
            writtenLines[inlet] = writtenLines[inlet]! + maxBufferSize;
            notifyListeners();
          }
        }, onError: (e) {
          if (buffer.isNotEmpty) {
            writeRow(sink, buffer);
            buffer.clear();
          }
          sink.close();
        });

        if (synchronize == null || !synchronize!) {
          final offsetStream =
              await worker?.startTimeCorrectionStream(inlet, onCancel: () {
            sink.close();
          });
          offsetStream?.listen((offset) {
            writeRow(offsetSink, [
              [offset.$1, offset.$2]
            ]);

            notifyListeners();
          });
        }
      }
    }

    notifyListeners();
  }

  Future<IOSink> openCsvFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName.csv';
    File file = File(filePath);

    int i = 2;
    while (await file.exists() && i < 100) {
      file = File("$filePath-${i++}");
    }

    return file.openWrite(mode: FileMode.append);
  }

  void writeRow(IOSink sink, List<List<dynamic>> rows) {
    String csvRow = '${const ListToCsvConverter().convert(rows)}\n';
    sink.write(csvRow);
  }
}
