import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:lsl_plugin/lsl_plugin.dart';

class OutletModel extends ChangeNotifier {
  final List<OutletManager> _outlets = [];

  /// An unmodifiable view of the int outlets
  UnmodifiableListView<OutletManager> get outlets =>
      UnmodifiableListView(_outlets);

  // /// The current total price of all items (assuming all items cost $42).
  // int get totalPrice => _items.length * 42;

  void add(OutletManager outlet) {
    _outlets.add(outlet);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  /// Removes all outlets
  void removeAll() {
    for (var outlet in _outlets) {
      outlet.destroy();
    }
    _outlets.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
