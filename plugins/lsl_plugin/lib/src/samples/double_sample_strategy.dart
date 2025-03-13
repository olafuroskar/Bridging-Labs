import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class DoubleSampleStrategy implements SampleStrategy<double> {
  final LslInterface _lsl;
  final lsl_outlet _outlet;
  final ChannelFormat _channelFormat;

  DoubleSampleStrategy(this._outlet, this._channelFormat, this._lsl);

  @override
  Result<Unit> pushSample(List<double> sample,
      [double? timestamp, bool pushthrough = false]) {
    switch (_channelFormat) {
      case ChannelFormat.float32:
        return allocateMemoryAndPush<Float>(sample, _outlet, _channelFormat);
      case ChannelFormat.double64:
        return allocateMemoryAndPush<Double>(sample, _outlet, _channelFormat);
      default:
        return sampleTypeChannelFormatMismatchError(
            sample[0].runtimeType.toString(), _channelFormat);
    }
  }

  /// Allocates the appropriate amount of memory for the given native type [T] and [channelFormat] and pushes the [sample] to the [outlet] stream
  Result<Unit> allocateMemoryAndPush<T extends NativeType>(
      List<double> sample, lsl_outlet outlet, ChannelFormat channelFormat,
      [double? timestamp, bool pushthrough = false]) {
    try {
      if (T == Float) {
        final nativeSamplePointer =
            malloc.allocate<Float>(sample.length * sizeOf<Float>());
        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = sample[i];
        }
        if (timestamp != null) {
          _lsl.bindings.lsl_push_sample_ftp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          _lsl.bindings.lsl_push_sample_f(outlet, nativeSamplePointer);
        }
      } else if (T == Double) {
        final nativeSamplePointer =
            malloc.allocate<Double>(sample.length * sizeOf<Double>());
        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = sample[i];
        }
        if (timestamp != null) {
          _lsl.bindings.lsl_push_sample_dtp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          _lsl.bindings.lsl_push_sample_d(outlet, nativeSamplePointer);
        }
      } else {
        return sampleTypeChannelFormatMismatchError(
            sample[0].runtimeType.toString(), _channelFormat);
      }

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
