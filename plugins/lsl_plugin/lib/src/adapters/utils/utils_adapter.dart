import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';

class UtilsAdapter {
  UtilsAdapter();

  /// {@template local_clock}
  /// Obtain a local system time stamp in seconds.
  ///
  /// The resolution is better than a millisecond.
  /// This reading can be used to assign time stamps to samples as they are being acquired.
  /// If the "age" of a sample is known at a particular time (e.g., from USB transmission
  /// delays), it can be used as an offset to [localClock] to obtain a better estimate of
  /// when a sample was actually captured. See [OutletManager.pushSample] for a use case.
  /// {@endtemplate}
  double localClock([double timeout = double.infinity]) {
    return lsl.bindings.lsl_local_clock();
  }
}
