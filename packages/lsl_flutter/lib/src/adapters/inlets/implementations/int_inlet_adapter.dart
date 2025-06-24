part of '../inlets.dart';

class IntInletAdapter extends InletAdapter<int> {
  /// {@template create_inlet}
  /// Construct a new stream inlet from a resolved stream info.
  ///
  /// [Inlet.streamInfo] A resolved stream info object (as coming from one of the resolver functions).
  /// Note: the [inlet] may also be constructed with a fully-specified [StreamInfo],
  /// if the desired channel format and count is already known up-front, but this is
  /// strongly discouraged and should only ever be done if there is no time to resolve the
  /// stream up-front (e.g., due to limitations in the client program).
  /// [Inlet.maxBufLen] Optionally the maximum amount of data to buffer (in seconds if there is a nominal
  /// sampling rate, otherwise x100 in samples). Recording applications want to use a fairly
  /// large buffer size here, while real-time applications would only buffer as much as
  /// they need to perform their next calculation.
  /// [Inlet.maxChunkLen] Optionally the maximum size, in samples, at which chunks are transmitted
  /// (the default corresponds to the chunk sizes used by the sender).
  /// Recording applications can use a generous size here (leaving it to the network how
  /// to pack things), while real-time applications may want a finer (perhaps 1-sample) granularity.
  /// If left unspecified (=0), the sender determines the chunk granularity.
  /// [Inlet.recover] Try to silently recover lost streams that are recoverable (=those that that have a sourceId set).
  /// In all other cases (recover is false or the stream is not recoverable) functions may throw a
  /// LostException if the stream's source is lost (e.g., due to an app or computer crash).
  /// {@endtemplate}
  IntInletAdapter._(Inlet<int> inlet, ResolvedStream stream) {
    final nativeInlet = lsl.bindings.lsl_create_inlet(stream.streamInfoPointer,
        inlet.maxBufLen, inlet.maxChunkLen, inlet.recover ? 1 : 0);

    _inletContainer = InletContainer._(inlet, nativeInlet);
  }

  @override
  Chunk<int>? pullChunk([double timeout = 0]) {
    final nativeInlet = _inletContainer._nativeInlet;

    final ec = malloc.allocate<Int32>(sizeOf<Int32>());

    final (dataBufferLength, timeStampBufferLength) =
        utils.getBufferLengths(_inletContainer);

    /// Allocate an array of length channelCount * maxChunkLen
    ///
    /// Example: 3 channels and max chunk length of 2
    /// [ [1, 2, 3], [4, 5, 6] ] -> [1, 2, 3, 4, 5, 6]
    final nativeSample =
        malloc.allocate<Int32>(dataBufferLength * sizeOf<Int32>());

    /// Allocate a corrisponding timestamp array for each sample in the chunk
    ///
    /// Following the above example
    /// [t1, t2, t3]
    final nativeTimestamps =
        malloc.allocate<Double>(timeStampBufferLength * sizeOf<Double>());

    final dataElementsWritten = lsl.bindings.lsl_pull_chunk_i(
        nativeInlet,
        nativeSample,
        nativeTimestamps,
        dataBufferLength,
        timeStampBufferLength,
        timeout,
        ec);

    final numSamples =
        dataElementsWritten / _inletContainer.inlet.streamInfo.channelCount;

    final Chunk<int> samples = [];

    for (var i = 0; i < numSamples; i++) {
      final List<int> sample = [];
      for (var j = 0; j < _inletContainer.inlet.streamInfo.channelCount; j++) {
        sample.add(nativeSample[
            i * _inletContainer.inlet.streamInfo.channelCount + j]);
      }
      // Arbitrary time limit, anything even remotely close to 0 is not valid
      if (nativeTimestamps[i] > 10) {
        samples.add((sample, nativeTimestamps[i]));
      }
    }

    checkError(ec);
    malloc.free(ec);
    malloc.free(nativeSample);
    malloc.free(nativeTimestamps);

    return samples;
  }

  @override
  Sample<int>? pullSample([double timeout = 0]) {
    final inlet = _inletContainer._nativeInlet;

    final ec = malloc.allocate<Int32>(sizeOf<Int32>());
    final nativeSample = malloc.allocate<Int32>(
        _inletContainer.inlet.streamInfo.channelCount * sizeOf<Int32>());

    final timestamp = lsl.bindings.lsl_pull_sample_i(inlet, nativeSample,
        _inletContainer.inlet.streamInfo.channelCount, timeout, ec);

    final List<int> sample = [];

    for (var i = 0; i < _inletContainer.inlet.streamInfo.channelCount; i++) {
      sample.add(nativeSample[i]);
    }

    checkError(ec);
    malloc.free(ec);
    malloc.free(nativeSample);

    return (sample, timestamp);
  }
}
