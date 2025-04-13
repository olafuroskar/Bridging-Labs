enum ProcessingOptions {
  /// No automatic post-processing; return the ground-truth time stamps for manual
  /// post-processing (this is the default behavior of the inlet).
  none(0),

  /// Perform automatic clock synchronization; equivalent to manually adding the
  /// [timeCorrection] value to the received time stamps.
  clockSync(1),

  /// Remove jitter from time stamps. This will apply a smoothing algorithm to the
  /// received time stamps the smoothing needs to see a minimum number of samples
  /// (30-120 seconds worst-case) until the remaining jitter is consistently below 1ms.
  dejitter(2),

  /// Force the time-stamps to be monotonically ascending (only makes sense if timestamps are dejittered).
  monotonize(4),

  /// Post-processing is thread-safe (same inlet can be read from by multiple threads); uses somewhat more CPU.
  threadsafe(8),

  /// The combination of all possible post-processing options.
  all(1 | 2 | 4 | 8);

  final int value;
  const ProcessingOptions(this.value);
}
