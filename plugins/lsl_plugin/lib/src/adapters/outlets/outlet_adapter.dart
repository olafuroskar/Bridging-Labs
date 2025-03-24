part of 'outlets.dart';

/// An interface for outlet repositories
abstract class OutletAdapter<S> {
  /// Gets the outlet container for the adapter instance
  ///
  /// The reference to the outlet is abstracted into this object to avoid it leaking to the manager layer.
  /// The [OutletContainer._nativeOutlet] reference is private to the outlet library.
  /// This furthermore allows us to specify common methods in this abstract class, but delegate the
  /// implementation of type specific methods like [pushSample] and [pushChunk] to inherited classes.
  OutletContainer getOutletContainer();

  /// {@template push_sample}
  /// Pushes a sample to the outlet
  ///
  /// [timestamp] An optional timestamp
  /// [pushthrough] Whether to push the sample through to the receivers instead of buffering it
  /// with subsequent samples. Note that the chunk_size, if specified at outlet construction, takes
  /// precedence over the pushthrough flag
  /// {@endtemplate}
  Result<Unit> pushSample(List<S> sample,
      [double? timestamp, bool pushthrough = false]);

  /// {@template push_chunk}
  /// Push a chunk of multiplexed samples into the outlet. Single timestamp provided.
  ///
  /// [chunk] A rectangular array of values for multiple samples.
  /// [timestamp] Optionally the capture time of the most recent sample, in agreement with local_clock(); if omitted, the current time is used.
  /// The time stamps of other samples are automatically derived based on the sampling rate of the stream.
  /// [pushthrough] Optionally whether to push the chunk through to the receivers instead of buffering it with subsequent samples.
  /// Note that the chunk_size, if specified at outlet construction, takes precedence over the pushthrough flag.
  /// {@endtemplate}
  Result<Unit> pushChunk(List<List<S>> chunk,
      [double? timestamp, bool pushthrough = false]);

  /// {@template destroy}
  /// Destroys the given outlet
  /// {@endtemplate}
  Result<Unit> destroy() {
    return utils.destroy(
      getOutletContainer()._nativeOutlet,
    );
  }

  /// {@template get_stream_info}
  /// Retrieve the stream info provided by this outlet.
  ///
  /// This is what was used to create the stream (and also has the Additional Network Information fields assigned).
  /// {@endtemplate}
  Result<StreamInfo> getStreamInfo() {
    return utils.getOutletStreamInfo(getOutletContainer()._nativeOutlet);
  }

  /// {@template have_consumers}
  /// Check whether consumers are currently registered.
  ///
  /// While it does not hurt, there is technically no reason to push samples if there is no consumer.
  /// {@endtemplate}
  Result<bool> haveConsumers() {
    return utils.haveConsumers(getOutletContainer()._nativeOutlet);
  }

  /// {@template wait_for_consumers}
  /// Wait until some consumer shows up (without wasting resources).
  ///
  /// returns true if the wait was successful, false if the [timeout] expired.
  /// {@endtemplate}
  Future<bool> waitForConsumers(double timeout) {
    return utils.waitForConsumers(getOutletContainer()._nativeOutlet, timeout);
  }
}
