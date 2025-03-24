part of '../outlets.dart';

class ShortOutletAdapter extends OutletAdapter<int> {
  late OutletContainer _outletContainer;

  /// {@macro create}
  ShortOutletAdapter._(Outlet<int> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Int16ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  OutletContainer getOutletContainer() {
    return _outletContainer;
  }

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      final nativeSamplePointer =
          malloc.allocate<Int16>(sample.length * sizeOf<Int16>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_stp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_s(outletPointer, nativeSamplePointer);
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
  Result<Unit> pushChunk(List<List<int>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer =
          malloc.allocate<Int16>(dataElements * channelCount * sizeOf<Int16>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_stp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings
            .lsl_push_chunk_s(outletPointer, nativeSamplePointer, dataElements);
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
