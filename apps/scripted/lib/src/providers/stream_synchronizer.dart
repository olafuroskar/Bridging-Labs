import 'dart:collection';

import 'package:lsl_flutter/lsl_flutter.dart';

class StreamSynchronizer {
  final double toleranceInSeconds;
  final double bufferIntervalInSeconds;
  final void Function(Sample<double>, Sample<double>) onSynchronized;
  final Map<String, List<Sample<double>>> buffers;
  final Map<String, double> thresholds;

  final List<Sample<double>> _slowBuffer = [];
  late final Queue<Sample<double>> _fastBuffer = Queue();

  final Map<String, bool> isFastSampleStream;
  final double fastThreshold;
  final double slowThreshold;

  double? _firstTimestamp;
  final double cooldownInSeconds;
  double? windowEndTimestamp;
  bool slowWindowEndReached = false;
  bool fastWindowEndRechhed = false;

  StreamSynchronizer({
    required this.toleranceInSeconds,
    this.bufferIntervalInSeconds = 2,
    required this.onSynchronized,
    required this.buffers,
    required this.thresholds,
    required this.isFastSampleStream,
    this.fastThreshold = 0,
    this.slowThreshold = 0,
    this.cooldownInSeconds = 0.5,
  });

  void _setFirstTimestamp(double timestamp) {
    if (_firstTimestamp != null) return;
    _firstTimestamp = timestamp;
    windowEndTimestamp = timestamp + bufferIntervalInSeconds;
  }

  void addSample(String streamId, Chunk<double> chunk) {
    final isFast = isFastSampleStream[streamId];
    if (isFast == null) return;

    _setFirstTimestamp(chunk.first.$2);

    if (isFast) {
      addFastSample(chunk);
    } else {
      addSlowSample(chunk);
    }
  }

  void bothWindowsEndReached() {
    /// If slow buffer has also passed the window end then we remove everything before the window end in both buffers.
    if (slowWindowEndReached && fastWindowEndRechhed) {
      _fastBuffer.removeWhere((fast) => fast.$2 < windowEndTimestamp!);
      _slowBuffer.removeWhere((slow) => slow.$2 < windowEndTimestamp!);
      slowWindowEndReached = false;
      fastWindowEndRechhed = false;
      windowEndTimestamp = windowEndTimestamp! + bufferIntervalInSeconds;
    }
  }

  void addSlowSample(Chunk<double> chunk) {
    _slowBuffer.addAll(chunk);
    // if (_cooldown(chunk.$2)) return;

    for (final slow in _slowBuffer) {
      for (final fast in _fastBuffer) {
        if ((fast.$2 - slow.$2).abs() <= toleranceInSeconds) {
          if (_checkCriteria(slow, fast)) {
            onSynchronized(fast, slow);
            _slowBuffer.remove(slow);
            break;
          }
        }
      }
    }

    _pruneOldSlowSamples(chunk.last.$2);
  }

  void _pruneOldSlowSamples(double now) {
    /// We are past the window end
    if (windowEndTimestamp != null && now > windowEndTimestamp!) {
      slowWindowEndReached = true;

      bothWindowsEndReached();
    }
  }

  void addFastSample(Chunk<double> fast) {
    _fastBuffer.addAll(fast);

    _pruneOldFastSamples(fast.last.$2);
  }

  void _pruneOldFastSamples(double now) {
    /// We are past the window end
    if (windowEndTimestamp != null && now > windowEndTimestamp!) {
      fastWindowEndRechhed = true;

      bothWindowsEndReached();
    }
  }

  bool _checkCriteria(Sample<double> slow, Sample<double> fast) {
    return slow.$1[0] < slowThreshold && fast.$1[0] < fastThreshold;
  }
}
