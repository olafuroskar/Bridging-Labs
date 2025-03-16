part of '../../lsl_plugin.dart';

class LongOutletRepository implements OutletRepository<int> {
  lsl_outlet? _outletPointer;

  /// {@macro bindings}
  static LslInterface _lsl = Lsl();
  static MulticastLock _multicastLock = MulticastLock();

  /// {@macro set_bindings}
  static void setBindings(LslInterface lsl) {
    _lsl = lsl;
  }

  static void setMulticastLock(MulticastLock multicastLock) {
    _multicastLock = multicastLock;
  }

  LongOutletRepository();

  @override
  Result<Unit> create(Outlet<int> outlet) {
    switch (createOutlet(_lsl, _multicastLock, outlet, Int64ChannelFormat())) {
      case Ok(value: var nativeOutlet):
        _outletPointer = nativeOutlet;
        return Result.ok(unit);
      case Error(error: var e):
        return unexpectedError("$e");
    }
  }

  @override
  Result<Unit> destroy() {
    return destroyOutlet(_lsl, _outletPointer, _multicastLock);
  }

  @override
  Result<Unit> pushSample(List<int> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutlet(_outletPointer);

      final nativeSamplePointer =
          malloc.allocate<Int64>(sample.length * sizeOf<Int64>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }
      if (timestamp != null) {
        _lsl.bindings.lsl_push_sample_ltp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        _lsl.bindings.lsl_push_sample_l(outletPointer, nativeSamplePointer);
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
      final outletPointer = getOutlet(_outletPointer);

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer =
          malloc.allocate<Int64>(dataElements * channelCount * sizeOf<Int64>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      if (timestamp != null) {
        _lsl.bindings.lsl_push_chunk_ltp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        _lsl.bindings
            .lsl_push_chunk_l(outletPointer, nativeSamplePointer, dataElements);
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
