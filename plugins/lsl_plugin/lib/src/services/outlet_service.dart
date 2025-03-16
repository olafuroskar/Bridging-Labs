part of '../../lsl_plugin.dart';

class OutletService<S, T extends ChannelFormat<S>> {
  int chunkSize;
  int maxBuffered;
  final StreamInfo<S> _streamInfo;

  OutletRepository<S>? _outletRepository;

  OutletService(this._streamInfo, [this.chunkSize = 0, this.maxBuffered = 360]);

  Result<Unit> create() {
    final outlet = Outlet<S>(_streamInfo, chunkSize, maxBuffered);

    OutletRepository<S>? outletRepository;

    if (S == int) {
      /// Get the appropriate outlet repository for the given integer channel format
      ///
      /// Here we have already established that S is in fact int
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<int>. The factory returns a narrower type but we must cast it back to a wider one.
      outletRepository =
          OutletRepositoryFactory.createIntRepositoryFromChannelFormat(
                  _streamInfo.channelFormat as ChannelFormat<int>)
              as OutletRepository<S>;
    } else if (S == double) {
      /// Get the appropriate outlet repository for the given double channel format
      ///
      /// Here we have already established that S is in fact double
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<double>. The factory returns a narrower type but we must cast it back to a wider one.
      outletRepository =
          OutletRepositoryFactory.createDoubleRepositoryFromChannelFormat(
                  _streamInfo.channelFormat as ChannelFormat<double>)
              as OutletRepository<S>;
    } else if (S == String) {
      /// Get the appropriate outlet repository for the given String channel format
      ///
      /// Here we have already established that S is in fact String
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<String>. The factory returns a narrower type but we must cast it back to a wider one.
      outletRepository =
          OutletRepositoryFactory.createStringRepositoryFromChannelFormat(
                  _streamInfo.channelFormat as ChannelFormat<String>)
              as OutletRepository<S>;
    } else {
      return Result.error(Exception("Unsupported type $S"));
    }

    final result = outletRepository.create(outlet);
    _outletRepository = outletRepository;

    return result;
  }

  /// {@macro push_sample}
  Result<Unit> pushSample(List<S> sample,
      [double? timestamp, bool pushthrough = false]) {
    return switch (getRepository(_outletRepository)) {
      Ok(value: var outletRepository) =>
        outletRepository.pushSample(sample, timestamp, pushthrough),
      Error(error: var e) => Result.error(e)
    };
  }

  /// {@macro push_chunk}
  Result<Unit> pushChunk(List<List<S>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    return switch (getRepository(_outletRepository)) {
      Ok(value: var outletRepository) =>
        outletRepository.pushChunk(chunk, timestamp, pushthrough),
      Error(error: var e) => Result.error(e)
    };
  }

  Result<Unit> destroy() {
    return switch (getRepository(_outletRepository)) {
      Ok(value: var outletRepository) => outletRepository.destroy(),
      Error(error: var e) => Result.error(e)
    };
  }
}
