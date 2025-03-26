part of '../inlets.dart';

class StringInletAdapter extends InletAdapter<String> {
  late InletContainer _inletContainer;
  late StreamInfo<String> _streamInfo;

  /// {@macro create_inlet}
  StringInletAdapter._(Inlet<String> inlet, ResolvedStream stream) {
    _streamInfo = inlet.streamInfo;

    final nativeInlet = lsl.bindings.lsl_create_inlet(stream.streamInfoPointer,
        inlet.maxBufLen, inlet.maxChunkLen, inlet.recover ? 1 : 0);

    _inletContainer = InletContainer._(inlet, nativeInlet);
  }

  @override
  Future<List<(List<String>, double)>?> pullChunk([double timeout = 0]) async {
    final nativeInlet = _getInletContainer()._nativeInlet;
    final inlet = _getInletContainer().inlet;

    return await Isolate.run(() {
      final ec = malloc.allocate<Int32>(sizeOf<Int32>());
      final dataBufferLength = _streamInfo.channelCount * inlet.maxChunkLen;
      final timeStampBufferLength = inlet.maxChunkLen;

      /// Allocate an array of length channelCount * maxChunkLen
      ///
      /// Example: 2 channels and max chunk length of 3
      /// [ [1, 2, 3], [4, 5, 6] ] -> [1, 2, 3, 4, 5, 6]
      final nativeSample = malloc
          .allocate<Pointer<Char>>(dataBufferLength * sizeOf<Pointer<Char>>());

      /// Allocate a corrisponding timestamp arra for each sample in the chunk
      ///
      /// Following the above example
      /// [t1, t2, t3]
      final nativeTimestamps =
          malloc.allocate<Double>(timeStampBufferLength * sizeOf<Double>());

      final numSamples = lsl.bindings.lsl_pull_chunk_str(
          nativeInlet,
          nativeSample,
          nativeTimestamps,
          dataBufferLength,
          timeStampBufferLength,
          timeout,
          ec);

      final List<(List<String>, double)> samples = [];

      for (var i = 0; i < numSamples; i++) {
        final List<String> sample = [];
        for (var j = 0; j < _streamInfo.channelCount; j++) {
          sample.add(nativeSample[i * _streamInfo.channelCount + j]
              .cast<Utf8>()
              .toDartString());
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
  Future<(List<String>, double)?> pullSample([double timeout = 0]) async {
    final inlet = _getInletContainer()._nativeInlet;

    return await Isolate.run(() {
      final ec = malloc.allocate<Int32>(sizeOf<Int32>());
      final nativeSample = malloc.allocate<Pointer<Char>>(
          _streamInfo.channelCount * sizeOf<Pointer<Char>>());

      final timestamp = lsl.bindings.lsl_pull_sample_str(
          inlet, nativeSample, _streamInfo.channelCount, timeout, ec);

      final List<String> sample = [];

      for (var i = 0; i < _streamInfo.channelCount; i++) {
        sample.add(nativeSample[i].cast<Utf8>().toDartString());
      }

      checkError(ec);
      malloc.free(ec);
      malloc.free(nativeSample);

      return (sample, timestamp);
    });
  }

  @override
  InletContainer _getInletContainer() {
    return _inletContainer;
  }
}
