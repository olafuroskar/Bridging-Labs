import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lsl_plugin/lsl_plugin.dart';

class InletModel extends ChangeNotifier {
  StreamManager streamManager = StreamManager();
  List<ResolvedStreamHandle<int>> _streams = [];
  final Map<String, InletManager<int>> _inlets = {};

  int maxLength = 10;
  List<(List<int> sample, double timestamp)> exampleSamples = [];

  /// An unmodifiable view of the int outlets
  UnmodifiableListView<ResolvedStreamHandle<int>> get streams =>
      UnmodifiableListView(_streams);

  /// An unmodifiable view of the int outlets
  UnmodifiableListView<String> get inlets => UnmodifiableListView(_inlets.keys);

  Future<void> resolveStreams(double waitTime) async {
    await streamManager.resolveStreams(waitTime);
    _streams = streamManager.getIntStreamHandles();

    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  bool createInlet(ResolvedStreamHandle<int> handle) {
    // This should perhaps be an id instead
    final key = handle.info.name;

    // Inlet has already been created for this stream
    if (_inlets.containsKey(key)) return false;

    final inletManager = streamManager.createInlet<int>(handle);
    switch (inletManager) {
      case Ok(value: var inlet):
        _inlets[key] = inlet;
        return true;
      case Error():
        return false;
    }
  }

  bool hasInlet(String name) {
    return _inlets.containsKey(name);
  }

  Future<(List<int>, double timestamp)?> pullSample(String name) async {
    final inlet = _inlets[name];

    if (inlet == null) throw Exception("inlet not found");

    final result = await inlet.pullSample();

    if (result != null) {
      addSample(result);
    }

    return result;
  }

  void addSample((List<int>, double) sample) {
    if (exampleSamples.length >= maxLength) {
      // Remove the first element
      exampleSamples.removeAt(0);
    }
    exampleSamples.add(sample);
  }

  /// Removes all outlets
  void removeAll() {
    for (var inlet in _inlets.values) {
      inlet.closeStream();
    }
    _streams.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
