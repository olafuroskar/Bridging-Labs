part of '../../lsl_flutter.dart';

/// A timestamp to be used when pushing samples or chunks
///
/// Using the [DateTime] class for timestamps comes naturally to Dart users, and the format of timestamps
/// in LSL is easy to get wrong. Therefore users are provided with a choice to either use a Dart timestamp
/// class that transforms the object to the proper double, or pass an LSL timestamp directly if they feel
/// confident in doing so.
sealed class Timestamp {
  const Timestamp();

  /// Returns the timestamp in Lsl format, i.e. seconds.
  double toLslTime();
}

/// A Dart type timstamp
///
/// If a user has access to samples that provide a timestamp in Dart DateTime format then this is convenient
/// to use.
class DartTimestamp extends Timestamp {
  /// The date time the object was created with
  final DateTime time;

  /// Creates an instance of [DartTimestamp] from the given datetime
  DartTimestamp(this.time);

  @override
  double toLslTime() {
    final unixSeconds = time.millisecondsSinceEpoch / 1000;
    final systemNow = DateTime.now().millisecondsSinceEpoch / 1000;
    final lslNow = lsl.bindings.lsl_local_clock();
    return lslNow + (unixSeconds - systemNow);
  }
}

/// A timestamp in LSL format
///
/// If performing the timestamp formatting manually is preferred, this class can be used.
class LslTimestamp extends Timestamp {
  /// The datetime in Lsl format that the object was created with
  final double time;

  /// Creates an instance of [LslTimestamp] from the given datetime in Lsl format
  LslTimestamp(this.time);
  @override
  double toLslTime() => time;
}
