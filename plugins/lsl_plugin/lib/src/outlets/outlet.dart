import 'package:lsl_plugin/src/utils/result.dart';

import '../utils/unit.dart';

abstract class Outlet<T> {
  /// Destroys the outlet.
  ///
  /// Should be called when the outlet is no longer in use.
  /// Consider also destroying the connected stream info.
  Result<Unit> destroy();

  /// Whether the outlet has been destroyed or not
  bool get isDestroyed;

  /// {@macro push_sample}
  Result<Unit> pushSample(List<T> sample,
      [double? timestamp, bool pushthrough = false]);
}
