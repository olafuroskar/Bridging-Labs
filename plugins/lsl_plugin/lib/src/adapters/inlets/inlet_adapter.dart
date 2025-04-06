part of 'inlets.dart';

abstract class InletAdapter<S> {
  /// The inlet container for the adapter instance
  ///
  /// Must be initialized in subclasses.
  /// Kept private to avoid it leaking to the manager layer.
  /// Defining the inlet here allows us to specify common methods in this abstract class, but delegate the
  /// implementation of type specific methods like [pullSample] and [pullChunk] to inherited classes.
  late InletContainer _inletContainer;

  /// {@template pull_sample}
  /// Pull a sample from the inlet and read it into an array of values.
  ///
  /// the sample on the remote machine, or null if no new sample was available.
  /// To remap this time stamp to the local clock, add the value returned by [timeCorrection] to it.
  /// returns a list containing the resulting values and the capture time of the sample
  ///
  /// [timeout] The timeout for this operation, if any. Use 0.0 to make the function non-blocking.
  /// {@endtemplate}
  Sample<S>? pullSample([double timeout = 0]);

  /// {@template pull_chunk}
  /// Pull a chunk of data from the inlet.
  ///
  /// may return before the entire buffer is filled. The default value of 0.0 will retrieve only
  /// data available for immediate pickup.
  /// returns a list of samples and corresponding capture times
  ///
  /// [timeout] Optionally the timeout for this operation, if any. When the timeout expires, the function
  /// {@endtemplate}
  Chunk<S>? pullChunk([double timeout = 0]);

  /// The following methods should not change on a type basis
  ///
  /// They can be overridden, but for now there is not a need

  /// {@template open_stream}
  /// Subscribe to the data stream.
  ///
  /// All samples pushed in at the other end from this moment onwards will be queued and
  /// eventually be delivered in response to [pullSample] or [pullChunk] calls.
  /// Pulling a sample without some preceding [openStream] is permitted (the stream will then be opened implicitly).
  ///
  /// [timeout] Optional timeout of the operation (default: no timeout).
  /// {@endtemplate}
  void openStream([double timeout = double.infinity]) {
    return utils.openStream(_inletContainer._nativeInlet, timeout);
  }

  /// {@template close_stream}
  /// Drop the current data stream.
  ///
  /// All samples that are still buffered or in flight will be dropped and transmission
  /// and buffering of data for this inlet will be stopped. If an application stops being
  /// interested in data from a source (temporarily or not) but keeps the outlet alive,
  /// it should call [closeStream] to not waste unnecessary system and network
  /// resources.
  /// {@endtemplate}
  void closeStream() {
    return utils.closeStream(_inletContainer._nativeInlet);
  }

  /// {@template get_inlet_stream_info}
  /// Retrieve the complete information of the given stream, including the extended description.
  ///
  /// Can be invoked at any time of the stream's lifetime.
  ///
  /// [timeout] Timeout of the operation (default: no timeout).
  /// {@endtemplate}
  StreamInfo getStreamInfo([double timeout = double.infinity]) {
    return utils.getInletStreamInfo(_inletContainer._nativeInlet, timeout);
  }

  /// {@template time_correction}
  /// Retrieve an estimated time correction offset for the given stream.
  ///
  /// The first call to this function takes several milliseconds until a reliable first estimate is obtained.
  /// Subsequent calls are instantaneous (and rely on periodic background updates).
  /// The precision of these estimates should be below 1 ms (empirically within +/-0.2 ms).
  /// Returns the time correction estimate. This is the number that needs to be added to a time stamp
  /// that was remotely generated via [lslLocalClock] to map it into the local clock domain of this machine.
  ///
  /// [timeout] Timeout to acquire the first time-correction estimate (default: no timeout).
  /// {@endtemplate}
  double timeCorrection([double timeout = double.infinity]) {
    return utils.timeCorrection(_inletContainer._nativeInlet, timeout);
  }

  /// {@template samples_available}
  ///  Query whether samples are currently available for immediate pickup.
  ///
  ///  Note that it is not a good idea to use [samplesAvailable] to determine whether
  ///  a [pullSample]/[pullChunk] call would block: to be sure, set the pull timeout to 0.0 or an acceptably
  ///  low value. If the underlying implementation supports it, the value will be the number of
  ///  samples available (otherwise it will be 1 or 0).
  /// {@endtemplate}
  int samplesAvailable() {
    return utils.samplesAvailable(_inletContainer._nativeInlet);
  }

  /// {@template was_clock_reset}
  /// Query whether the clock was potentially reset since the last call to [wasClockReset].
  ///
  /// This is a rarely-used function that is only useful to applications that combine multiple [timeCorrection]
  /// values to estimate precise clock drift; it allows to tolerate cases where the source machine was
  /// hot-swapped or restarted in between two measurements.
  /// {@endtemplate}
  bool wasClockReset() {
    return utils.wasClockReset(_inletContainer._nativeInlet);
  }
}
