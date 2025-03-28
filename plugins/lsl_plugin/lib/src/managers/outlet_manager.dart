part of 'managers.dart';

/// A service for interacting with a single outlet
///
/// An instance can be re-used for multiple outlets (after being destroyed of course), but
/// creaing new instances instead is incouraged for clarity.
class OutletManager<S> {
  late int chunkSize;
  late int maxBuffered;
  late StreamInfo<S> _streamInfo;

  late OutletAdapter<S> _outletAdapter;

  /// {@macro create}
  OutletManager(StreamInfo<S> streamInfo,
      [int outletChunkSize = 0, int outletMaxBuffered = 360]) {
    _streamInfo = streamInfo;
    chunkSize = outletChunkSize;
    maxBuffered = outletMaxBuffered;
    final outlet = Outlet<S>(_streamInfo, chunkSize, maxBuffered);

    OutletAdapter<S>? outletAdapter;

    if (S == int) {
      /// Get the appropriate outlet adapter for the given integer channel format
      ///
      /// Here we have already established that S is in fact int
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<int>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createIntAdapterFromChannelFormat(
          outlet as Outlet<int>) as OutletAdapter<S>;
    } else if (S == double) {
      /// Get the appropriate outlet adapter for the given double channel format
      ///
      /// Here we have already established that S is in fact double
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<double>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createDoubleAdapterFromChannelFormat(
          outlet as Outlet<double>) as OutletAdapter<S>;
    } else if (S == String) {
      /// Get the appropriate outlet adapter for the given String channel format
      ///
      /// Here we have already established that S is in fact String
      /// Furthermore, from the `T extends ChannelFormat<T>` type constraint we know that streamInfo.channelFormat
      /// must be of type ChannelFormat<String>. The factory returns a narrower type but we must cast it back to a wider one.
      outletAdapter = OutletAdapterFactory.createStringAdapterFromChannelFormat(
          outlet as Outlet<String>) as OutletAdapter<S>;
    } else {
      throw Exception("Unsupported type $S");
    }

    _outletAdapter = outletAdapter;
  }

  /// {@macro push_sample}
  void pushSample(List<S> sample,
      [double? timestamp, bool pushthrough = false]) {
    return _outletAdapter.pushSample(sample, timestamp, pushthrough);
  }

  /// {@macro push_chunk}
  void pushChunk(List<List<S>> chunk,
      [double? timestamp, bool pushthrough = false]) {
    return _outletAdapter.pushChunk(chunk, timestamp, pushthrough);
  }

  /// {@macro push_chunk_with_timestamps}
  void pushChunkWithTimastamps(List<List<S>> chunk, List<double> timestamps,
      [bool pushthrough = false]) {
    return _outletAdapter.pushChunkWithTimestamps(
        chunk, timestamps, pushthrough);
  }

  /// {@macro destroy}
  void destroy() {
    return _outletAdapter.destroy();
  }

  /// {@macro get_stream_info}
  StreamInfo getStreamInfo() {
    return _outletAdapter.getStreamInfo();
  }

  /// {@macro have_consumers}
  bool haveConsumers() {
    return _outletAdapter.haveConsumers();
  }

  /// {@macro wait_for_consumers}
  Future<bool> waitForConsumers(double timeout) {
    return _outletAdapter.waitForConsumers(timeout);
  }
}
