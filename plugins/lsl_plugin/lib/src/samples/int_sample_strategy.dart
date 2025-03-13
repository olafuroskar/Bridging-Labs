import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class IntSampleStrategy implements SampleStrategy<int> {
  final lsl_outlet _outlet;
  final ChannelFormat _channelFormat;

  IntSampleStrategy(this._outlet, this._channelFormat);

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    switch (_channelFormat) {
      case ChannelFormat.int8:
        return allocateMemoryAndPush<Int8>(
            sample, _outlet, _channelFormat, timestamp, pushthrough);
      case ChannelFormat.int16:
        return allocateMemoryAndPush<Int16>(
            sample, _outlet, _channelFormat, timestamp, pushthrough);
      case ChannelFormat.int32:
        return allocateMemoryAndPush<Int32>(
            sample, _outlet, _channelFormat, timestamp, pushthrough);
      case ChannelFormat.int64:
        return allocateMemoryAndPush<Int64>(
            sample, _outlet, _channelFormat, timestamp, pushthrough);
      default:
        return sampleTypeChannelFormatMismatchError(
            sample[0].runtimeType.toString(), _channelFormat);
    }
  }

  /// Allocates the appropriate amount of memory for the given native type [T] and [channelFormat] and pushes the [sample] to the [outlet] stream
  Result<Unit> allocateMemoryAndPush<T extends NativeType>(
      List<int> sample, lsl_outlet outlet, ChannelFormat channelFormat,
      [double? timestamp, bool pushthrough = false]) {
    try {
      if (T == Int8 || T == Int16) {
        final nativeSamplePointer =
            malloc.allocate<Int16>(sample.length * sizeOf<Int16>());
        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = sample[i];
        }
        if (timestamp != null) {
          bindings.lsl_push_sample_stp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          bindings.lsl_push_sample_s(outlet, nativeSamplePointer);
        }
      } else if (T == Int32) {
        final nativeSamplePointer =
            malloc.allocate<Int32>(sample.length * sizeOf<Int32>());
        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = sample[i];
        }
        if (timestamp != null) {
          bindings.lsl_push_sample_itp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          bindings.lsl_push_sample_i(outlet, nativeSamplePointer);
        }
      } else if (T == Int64) {
        final nativeSamplePointer =
            malloc.allocate<Int64>(sample.length * sizeOf<Int64>());
        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = sample[i];
        }
        if (timestamp != null) {
          bindings.lsl_push_sample_ltp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          bindings.lsl_push_sample_l(outlet, nativeSamplePointer);
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
