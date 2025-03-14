import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class FloatSampleStrategy implements SampleStrategy<double> {
  final lsl_outlet _outlet;
  final LslInterface _lsl;

  FloatSampleStrategy(this._outlet, this._lsl);

  @override
  Result<Unit> pushSample(List<double> sample,
      [double? timestamp, bool pushthrough = false]) {
    try {
      final nativeSamplePointer =
          malloc.allocate<Float>(sample.length * sizeOf<Float>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        _lsl.bindings.lsl_push_sample_ftp(
            _outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        _lsl.bindings.lsl_push_sample_f(_outlet, nativeSamplePointer);
      }
      malloc.free(nativeSamplePointer);
      return Result.ok(unit);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
