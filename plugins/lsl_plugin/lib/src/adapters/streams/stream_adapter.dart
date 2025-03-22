import 'package:lsl_plugin/lsl_plugin.dart';

abstract class StreamAdapter {
  Future<List<ResolvedStreamHandle>> resolveStreams(double double);

  // TODO: createInlet
  // Consider removing from the stored handles as refreshing may destroy the stream infos
}
