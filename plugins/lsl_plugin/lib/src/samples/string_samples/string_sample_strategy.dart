import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class StringSampleStrategy implements SampleStrategy<String> {
  final lsl_outlet _outlet;
  final LslInterface _lsl;

  StringSampleStrategy(this._outlet, this._lsl);

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();
      final encodedStrings = sample.map(toString).toList();

      final nativeSamplePointer = malloc
          .allocate<Pointer<Char>>(sample.length * sizeOf<Pointer<Char>>());

      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = encodedStrings[i];
      }

      if (timestamp != null) {
        _lsl.bindings.lsl_push_sample_strtp(
            _outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        _lsl.bindings.lsl_push_sample_str(_outlet, nativeSamplePointer);
      }

      for (var ptr in encodedStrings) {
        malloc.free(ptr);
      }
      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
