part of '../inlets.dart';

class ShortInletAdapter extends InletAdapter<int> {
  /// {@macro create_inlet}
  ShortInletAdapter._(Inlet<int> inlet, ResolvedStream stream) {
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
        malloc.allocate<Int16>(dataBufferLength * sizeOf<Int16>());

    /// Allocate a corrisponding timestamp arra for each sample in the chunk
    ///
    /// Following the above example
    /// [t1, t2, t3]
    final nativeTimestamps =
        malloc.allocate<Double>(timeStampBufferLength * sizeOf<Double>());

    final numSamples = lsl.bindings.lsl_pull_chunk_s(nativeInlet, nativeSample,
        nativeTimestamps, dataBufferLength, timeStampBufferLength, timeout, ec);

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
    final nativeSample = malloc.allocate<Int16>(
        _inletContainer.inlet.streamInfo.channelCount * sizeOf<Int16>());

    final timestamp = lsl.bindings.lsl_pull_sample_s(inlet, nativeSample,
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
