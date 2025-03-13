import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/samples/sample_strategy.dart';
import 'package:lsl_plugin/src/samples/utils.dart';
import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class StringSampleStrategy implements SampleStrategy<String> {
  final LslInterface _lsl;

  final lsl_outlet _outlet;
  final ChannelFormat _channelFormat;

  StringSampleStrategy(this._outlet, this._channelFormat, this._lsl);

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    switch (_channelFormat) {
      case ChannelFormat.string:
        return allocateMemoryAndPush(
            sample, _outlet, _channelFormat, timestamp, pushthrough);
      default:
        return sampleTypeChannelFormatMismatchError(
            sample[0].runtimeType.toString(), _channelFormat);
    }
  }

  /// Allocates the appropriate amount of memory for the given native type [T] and [channelFormat] and pushes the [sample] to the [outlet] stream
  Result<Unit> allocateMemoryAndPush<T extends NativeType>(
      List<String> sample, lsl_outlet outlet, ChannelFormat channelFormat,
      [double? timestamp, bool pushthrough = false]) {
    try {
      if (T == Char) {
        Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();
        final encodedStrings = sample.map(toString).toList();

        final nativeSamplePointer = malloc
            .allocate<Pointer<Char>>(sample.length * sizeOf<Pointer<Char>>());

        for (var i = 0; i < sample.length; i++) {
          nativeSamplePointer[i] = encodedStrings[i];
        }

        if (timestamp != null) {
          _lsl.bindings.lsl_push_sample_strtp(
              outlet, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
        } else {
          _lsl.bindings.lsl_push_sample_str(outlet, nativeSamplePointer);
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
