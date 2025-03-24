import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lsl_plugin/lsl_plugin.dart';

class OutletModel extends ChangeNotifier {
  final Map<String, OutletManager> _outlets = {};

  /// An unmodifiable view of the int outlets
  UnmodifiableListView<String> get outlets =>
      UnmodifiableListView(_outlets.keys);

  void add(String name) {
    final streamInfo = StreamInfoFactory.createIntStreamInfo(
        name, "EEG", Int32ChannelFormat());

    final manager = OutletManager(streamInfo);
    final result = manager.create();

    switch (result) {
      case Error(error: var e):
        throw e;
      case Ok():
        _outlets[name] = manager;
    }
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void pushSample(String name, List<int> sample) {
    final outlet = _outlets[name];

    if (outlet == null) throw Exception("Outlet not found");

    outlet.pushSample(sample);
  }

  /// Removes all outlets
  void removeAll() {
    for (var outlet in _outlets.values) {
      outlet.destroy();
    }
    _outlets.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
