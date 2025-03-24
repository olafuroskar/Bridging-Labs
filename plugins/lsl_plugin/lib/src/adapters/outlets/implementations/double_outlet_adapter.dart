part of '../outlets.dart';

class DoubleOutletAdapter extends OutletAdapter<double> {
  late OutletContainer _outletContainer;

  /// {@template create}
  /// Creates an outlet stream from the given [outlet] object
  /// {@endtemplate}
  DoubleOutletAdapter._(Outlet<double> outlet) {
    final nativeOutlet = utils.createOutlet(outlet, Double64ChannelFormat());
    _outletContainer = OutletContainer._(outlet, nativeOutlet);
  }

  @override
  OutletContainer getOutletContainer() {
    return _outletContainer;
  }

  @override
  Result<Unit> pushSample(List<double> sample,
      [double? timestamp, bool pushthrough = false]) {
    if (sample.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      final nativeSamplePointer =
          malloc.allocate<Double>(sample.length * sizeOf<Double>());
      for (var i = 0; i < sample.length; i++) {
        nativeSamplePointer[i] = sample[i];
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_sample_dtp(
            outletPointer, nativeSamplePointer, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings.lsl_push_sample_d(outletPointer, nativeSamplePointer);
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
  Result<Unit> pushChunk(List<List<double>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    if (chunk.isEmpty) {
      return Result.ok(unit);
    }

    try {
      final outletPointer = getOutletContainer()._nativeOutlet;

      final dataElements = chunk.length;
      final channelCount = chunk[0].length;

      final nativeSamplePointer = malloc
          .allocate<Double>(dataElements * channelCount * sizeOf<Double>());
      for (var i = 0; i < dataElements; i++) {
        for (var j = 0; j < channelCount; j++) {
          nativeSamplePointer[i * dataElements + j] = chunk[i][j];
        }
      }

      if (timestamp != null) {
        lsl.bindings.lsl_push_chunk_dtp(outletPointer, nativeSamplePointer,
            dataElements, timestamp, pushthrough ? 1 : 0);
      } else {
        lsl.bindings
            .lsl_push_chunk_d(outletPointer, nativeSamplePointer, dataElements);
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
