import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/inlets/inlets.dart';

abstract class StreamAdapter {
  void resolveStreams(double double);

  InletAdapter<S> createInlet<S>(ResolvedStreamHandle<S> handle);
  // Consider removing from the stored handles as refreshing may destroy the stream infos

  /// Gets the handles for the currently saved int streams
  List<ResolvedStreamHandle<int>> getIntStreamHandles();

  /// Gets the handles for the currently saved double streams
  List<ResolvedStreamHandle<double>> getDoubleStreamHandles();

  /// Gets the handles for the currently saved String streams
  List<ResolvedStreamHandle<String>> getStringStreamHandles();

  /// Destroy local instances the currently saved streams
  void destroyStreams();
}
