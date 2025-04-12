part of '../../main.dart';

class InletProvider extends ChangeNotifier {
  int maxBufferSize = 150;
  bool? synchronize = false;

  Map<String, int> writtenLines = {};

  List<ResolvedStreamHandle<Object?>> handles = [];

  List<String> selectedInlets = [];
  StreamManager streamManager = StreamManager();
  final Map<String, (InletManager<Object?>, StreamSubscription<Chunk<Object?>>)>
      inlets = {};

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
    worker?.close();
  }

  Future<void> resolveStreams(double waitTime) async {
    worker ??= await InletWorker.spawn();

    handles = await worker?.resolveStreams() ?? [];

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void closeInlet(String key) {
    worker?.stop(key);
  }

  void shareResult(String key) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$key.csv';
    await Share.shareXFiles([XFile(filePath)]);
  }

  void createInlet({Map<String, List<String>?>? columnNames}) async {
    for (var inlet in selectedInlets) {
      final sink = await openCsvFile(inlet);
      if (columnNames != null && columnNames[inlet] != null) {
        final columns = columnNames[inlet];
        if (columns != null) {
          writeRow(sink, [columns]);
        }
      }

      final List<List<dynamic>> buffer = [];
      writtenLines[inlet] = 0;

      final opened =
          await worker?.open(inlet, synchronize: synchronize ?? false);

      if (opened != null && opened) {
        final chunkStream = await worker?.startChunkStream(inlet);
        chunkStream?.listen((chunk) {
          buffer.addAll(chunk.map((item) =>
              [item.$2.toString()] +
              item.$1.map((x) => x.toString()).toList()));

          if (buffer.length > maxBufferSize) {
            print("🫡 Writing");

            writeRow(sink, buffer);
            buffer.clear();
            writtenLines[inlet] = writtenLines[inlet]! + maxBufferSize;
            notifyListeners();
          }
        }, onDone: () {
          if (buffer.isNotEmpty) {
            writeRow(sink, buffer);
          }
          sink.close();
        });
      }
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
