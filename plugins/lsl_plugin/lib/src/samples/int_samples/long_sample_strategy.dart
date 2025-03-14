import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class LongSampleStrategy implements SampleStrategy<int> {
  final lsl_outlet _outlet;
  final LslInterface _lsl;

  LongSampleStrategy(this._outlet, this._lsl);

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    try {
      final nativeSamplePointer =
          malloc.allocate<Int64>(sample.length * sizeOf<Int64>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        _lsl.bindings.lsl_push_sample_ltp(
            _outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        _lsl.bindings.lsl_push_sample_l(_outlet, nativeSamplePointer);
      }
      malloc.free(nativeSamplePointer);
      return Result.ok(unit);
    } catch (e) {
      return Result.error(Exception("An unknown exception encountered: $e"));
    }
  }
}
