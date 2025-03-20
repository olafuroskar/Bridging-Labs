import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

/// An interface for outlet repositories
abstract class OutletAdapter<S> {
  /// {@template create}
  /// Creates an outlet stream from the given [outlet] object
  /// {@endtemplate}
  Result<Unit> create(Outlet<S> outlet);

  /// {@template destroy}
  /// Destroys the given outlet
  /// {@endtemplate}
  Result<Unit> destroy();

  /// {@template push_sample}
  /// Pushes a sample to the outlet
  ///
  /// [timestamp] An optional timestamp
  /// [pushthrough] Whether to push the sample through to the receivers instead of buffering it
  /// with subsequent samples. Note that the chunk_size, if specified at outlet construction, takes
  /// precedence over the pushthrough flag
  /// {@endtemplate}
  Result<Unit> pushSample(List<S> sample,
      [double? timestamp, bool pushthrough = false]);

  /// {@template push_chunk}
  /// Push a chunk of multiplexed samples into the outlet. Single timestamp provided.
  ///
  /// [chunk] A rectangular array of values for multiple samples.
  /// [timestamp] Optionally the capture time of the most recent sample, in agreement with local_clock(); if omitted, the current time is used.
  /// The time stamps of other samples are automatically derived based on the sampling rate of the stream.
  /// [pushthrough] Optionally whether to push the chunk through to the receivers instead of buffering it with subsequent samples.
  /// Note that the chunk_size, if specified at outlet construction, takes precedence over the pushthrough flag.
  /// {@endtemplate}
  Result<Unit> pushChunk(List<List<S>> chunk,
      [double? timestamp, bool pushthrough = false]);

  /// {@template get_stream_info}
  /// Retrieve the stream info provided by this outlet.
  ///
  /// This is what was used to create the stream (and also has the Additional Network Information fields assigned).
  /// {@endtemplate}
  Result<StreamInfo> getStreamInfo();

  // TODO:
  // haveConsumers
  // waitForConsumers - might need isolate
}
