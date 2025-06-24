part of '../../lsl_flutter.dart';

/// Converts an interval (from a [Duration] object) to its corresponding frequency in Hz
///
/// If interval provided is 1 second or more 1Hz is returned.
/// If interval provided is 0 then the maximum of 1000 Hz id returned.
double intervalToFrequency(Duration duration) {
  if (duration.inSeconds > 0) {
    return 1;
  }
  if (duration.inMilliseconds == 0) {
    return 1000;
  }
  return 1000 / duration.inMilliseconds;
}
