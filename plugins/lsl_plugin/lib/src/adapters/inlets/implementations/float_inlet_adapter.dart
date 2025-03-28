part of '../inlets.dart';

class FloatInletAdapter extends InletAdapter<double> {
  /// {@macro create_inlet}
  FloatInletAdapter._(Inlet<double> inlet, ResolvedStream stream) {
    final nativeInlet = lsl.bindings.lsl_create_inlet(stream.streamInfoPointer,
        inlet.maxBufLen, inlet.maxChunkLen, inlet.recover ? 1 : 0);

    _inletContainer = InletContainer._(inlet, nativeInlet);
  }

  @override
  Future<List<(List<double>, double)>?> pullChunk([double timeout = 0]) async {
    final nativeInlet = _inletContainer._nativeInlet;

    return await Isolate.run(() {
      final ec = malloc.allocate<Int32>(sizeOf<Int32>());

      final (dataBufferLength, timeStampBufferLength) =
          utils.getBufferLengths(_inletContainer);

      /// Allocate an array of length channelCount * maxChunkLen
      ///
      /// Example: 2 channels and max chunk length of 3
      /// [ [1, 2, 3], [4, 5, 6] ] -> [1, 2, 3, 4, 5, 6]
      final nativeSample =
          malloc.allocate<Float>(dataBufferLength * sizeOf<Float>());

      /// Allocate a corrisponding timestamp arra for each sample in the chunk
      ///
      /// Following the above example
      /// [t1, t2, t3]
      final nativeTimestamps =
          malloc.allocate<Double>(timeStampBufferLength * sizeOf<Double>());

      final numSamples = lsl.bindings.lsl_pull_chunk_f(
          nativeInlet,
          nativeSample,
          nativeTimestamps,
          dataBufferLength,
          timeStampBufferLength,
          timeout,
          ec);

      final List<(List<double>, double)> samples = [];

      for (var i = 0; i < numSamples; i++) {
        final List<double> sample = [];
        for (var j = 0;
            j < _inletContainer.inlet.streamInfo.channelCount;
            j++) {
          sample.add(nativeSample[
              i * _inletContainer.inlet.streamInfo.channelCount + j]);
        }
        samples.add((sample, nativeTimestamps[i]));
      }

      checkError(ec);
      malloc.free(ec);
      malloc.free(nativeSample);
      malloc.free(nativeTimestamps);

      return samples;
    });
  }

  @override
  Future<(List<double>, double)?> pullSample([double timeout = 0]) async {
    final inlet = _inletContainer._nativeInlet;

    return await Isolate.run(() {
      final ec = malloc.allocate<Int32>(sizeOf<Int32>());
      final nativeSample = malloc.allocate<Float>(
          _inletContainer.inlet.streamInfo.channelCount * sizeOf<Float>());

      final timestamp = lsl.bindings.lsl_pull_sample_f(inlet, nativeSample,
          _inletContainer.inlet.streamInfo.channelCount, timeout, ec);

      final List<double> sample = [];

      for (var i = 0; i < _inletContainer.inlet.streamInfo.channelCount; i++) {
        sample.add(nativeSample[i]);
      }

      checkError(ec);
      malloc.free(ec);
      malloc.free(nativeSample);

      return (sample, timestamp);
    });
  }
}
