part of '../../lsl_plugin.dart';

/// A service for interacting with a single outlet
///
/// An instance can be re-used for multiple outlets (after being destroyed of course), but
/// creaing new instances instead is incouraged for clarity.
class OutletManager<S> {
  int chunkSize;
  int maxBuffered;
  final StreamInfo<S> _streamInfo;

  OutletAdapter<S>? _outletAdapter;

  OutletManager(this._streamInfo, [this.chunkSize = 0, this.maxBuffered = 360]);

  /// {@macro create}
  Result<Unit> create() {
    final outlet = Outlet<S>(_streamInfo, chunkSize, maxBuffered);

    OutletAdapter<S>? outletAdapter;

    if (S == int) {
      /// Get the appropriate outlet repository for the given integer channel format
      ///
      /// Here we have already established that S is in fact int
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<int>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createIntRepositoryFromChannelFormat(
          _streamInfo.channelFormat as ChannelFormat<int>) as OutletAdapter<S>;
    } else if (S == double) {
      /// Get the appropriate outlet repository for the given double channel format
      ///
      /// Here we have already established that S is in fact double
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<double>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter =
          OutletAdapterFactory.createDoubleRepositoryFromChannelFormat(
                  _streamInfo.channelFormat as ChannelFormat<double>)
              as OutletAdapter<S>;
    } else if (S == String) {
      /// Get the appropriate outlet repository for the given String channel format
      ///
      /// Here we have already established that S is in fact String
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<String>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter =
          OutletAdapterFactory.createStringRepositoryFromChannelFormat(
                  _streamInfo.channelFormat as ChannelFormat<String>)
              as OutletAdapter<S>;
    } else {
      return Result.error(Exception("Unsupported type $S"));
    }

    final result = outletAdapter.create(outlet);
    _outletAdapter = outletAdapter;

    return result;
  }

  /// {@macro push_sample}
  Result<Unit> pushSample(List<S> sample,
      [double? timestamp, bool pushthrough = false]) {
    return switch (getAdapter(_outletAdapter)) {
      Ok(value: var outletAdapter) =>
        outletAdapter.pushSample(sample, timestamp, pushthrough),
      Error(error: var e) => Result.error(e)
    };
  }

  /// {@macro push_chunk}
  Result<Unit> pushChunk(List<List<S>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    return switch (getAdapter(_outletAdapter)) {
      Ok(value: var outletAdapter) =>
        outletAdapter.pushChunk(chunk, timestamp, pushthrough),
      Error(error: var e) => Result.error(e)
    };
  }

  /// {@macro destroy}
  Result<Unit> destroy() {
    return switch (getAdapter(_outletAdapter)) {
      Ok(value: var outletAdapter) => outletAdapter.destroy(),
      Error(error: var e) => Result.error(e)
    };
  }

  /// {@macro get_stream_info}
  Result<StreamInfo> getStreamInfo() {
    return switch (getAdapter(_outletAdapter)) {
      Ok(value: var outletAdapter) => outletAdapter.getStreamInfo(),
      Error(error: var e) => Result.error(e)
    };
  }

  Result<bool> haveConsumers() {
    // TODO: Implement
    throw Exception("Not implemented");
  }

  Result<bool> waitForConsumers() {
    // TODO: Implement
    throw Exception("Not implemented");
  }
}
