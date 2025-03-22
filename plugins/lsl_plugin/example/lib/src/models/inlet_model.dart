import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lsl_plugin/lsl_plugin.dart';

class InletModel extends ChangeNotifier {
  StreamManager streamManager = StreamManager();
  List<ResolvedStreamHandle> _streams = [];

  /// An unmodifiable view of the int outlets
  UnmodifiableListView<ResolvedStreamHandle> get streams =>
      UnmodifiableListView(_streams);

  Future<void> resolveStreams(double waitTime) async {
    final streamHandles = await streamManager.resolveStreams(waitTime);

    print(streamHandles);
    _streams = streamHandles;
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all outlets
  void removeAll() {
    // for (var outlet in _outlets) {
    //   outlet.destroy();
    // }
    _streams.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
