import 'package:lsl_flutter/lsl_flutter.dart';

class StreamSynchronizer {
  final double tolerance;
  final void Function(Map<String, Sample<double>>) onSynchronized;
  final Map<String, List<Sample<double>>> buffers;
  final Map<String, double> thresholds;

  StreamSynchronizer({
    required this.tolerance,
    required this.onSynchronized,
    required this.buffers,
    required this.thresholds,
  });

  void addSample(String streamId, Sample<double> sample) {
    final buffer = buffers[streamId];
    if (buffer == null) return;

    // Insert sample maintaining sort order (or just append if guaranteed sorted)
    buffer.add(sample);
    // buffer.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    _trySynchronize();
  }

  void _trySynchronize() {
    // Find earliest common time range with all buffers non-empty
    final latestMins = buffers.values
        .where((buf) => buf.isNotEmpty)
        .map((buf) => buf.first.$2)
        .toList();

    if (latestMins.length < buffers.length) return;

    final commonTime = latestMins.reduce((a, b) => a > b ? a : b);

    // Try to extract samples from each buffer at around `commonTime`
    final alignedSamples = <String, Sample<double>>{};

    for (final entry in buffers.entries) {
      final closest = entry.value.firstWhere(
        (s) => (s.$2 - commonTime).abs() <= tolerance,
        orElse: () => ([], double.nan),
      );

      if (closest.$1.isEmpty || closest.$2.isNaN) return;

      alignedSamples[entry.key] = closest;
    }

    // Check custom criteria
    if (alignedSamples.length == buffers.length &&
        _checkCriteria(alignedSamples)) {
      onSynchronized(alignedSamples);
    }

    // Flush samples older than the minimum time
    for (final buffer in buffers.values) {
      buffer.removeWhere((s) => s.$2 <= commonTime);
    }
  }

  bool _checkCriteria(Map<String, Sample<double>> samples) {
    // Implement your own condition here
    for (final entry in samples.entries) {
      final threshold = thresholds[entry.key];
      if (threshold == null) return false;

      final value = entry.value.$1[0];
      if (value > threshold) return false;
    }
    return true;
  }
}
