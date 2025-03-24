part of '../outlets.dart';

class StringOutletAdapter extends OutletAdapter<String> {
  late OutletContainer _outletContainer;

  /// {@macro create}
  StringOutletAdapter._(Outlet<String> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, CftStringChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  OutletContainer getOutletContainer() {
    return _outletContainer;
  }

  @override
  Result<Unit> pushSample(List<String> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();
      final encodedStrings = sample.map(toString).toList();

      final nativeSamplePointer = malloc
          .allocate<Pointer<Char>>(sample.length * sizeOf<Pointer<Char>>());

      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = encodedStrings[i];
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_strtp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_str(outletPointer, nativeSamplePointer);
      }

      for (var ptr in encodedStrings) {
        malloc.free(ptr);
      }
      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  @override
  Result<Unit> pushChunk(List<List<String>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      Pointer<Char> toString(String text) => text.toNativeUtf8().cast<Char>();

      final nativeSamplePointer = malloc.allocate<Pointer<Char>>(
          dataElements * channelCount * sizeOf<Pointer<Char>>());

      for (var i = 0; i < dataElements; i++) {
        final encodedStrings = chunk[i].map(toString).toList();
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = encodedStrings[j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_strtp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_chunk_str(
            outletPointer, nativeSamplePointer, dataElements);
      }

      malloc.free(nativeSamplePointer);

      return Result.ok(unit);
    } on Exception catch (e) {
      return Result.error(e);
    } catch (e) {
      return unexpectedError("$e");
    }
  }
}
