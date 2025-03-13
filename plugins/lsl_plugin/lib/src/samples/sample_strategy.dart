import 'package:lsl_plugin/src/utils/result.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

/// An interface for sample strategies
abstract class SampleStrategy<T> {
  /// {@template push_sample}
  /// Pushes a sample to the outlet
  ///
  /// [timestamp] An optional timestamp
  /// [pushthrough] Whether to push the sample through to the receivers instead of buffering it
  /// with subsequent samples. Note that the chunk_size, if specified at outlet construction, takes
  /// precedence over the pushthrough flag
  /// {@endtemplate}
  Result<Unit> pushSample(List<T> sample,
      [double? timestamp, bool pushthrough = false]);
}
