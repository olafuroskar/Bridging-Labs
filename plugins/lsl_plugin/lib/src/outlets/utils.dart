import 'package:android_multicast_lock/android_multicast_lock.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

Result<Unit> destroyOutlet(
    LslInterface lsl, lsl_outlet outlet, MulticastLock multicastLock) {
  try {
    lsl.bindings.lsl_destroy_outlet(outlet);
    multicastLock.release();
    return Result.ok(unit);
  } catch (e) {
    return unexpectedError("$e");
  }
}
