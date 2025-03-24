import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/outlets/outlets.dart';
import 'package:lsl_plugin/src/adapters/streams/stream_adapter.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';

/// "Unwraps" the nullable outlet adapter
///
/// {@macro non_null_members}
Result<OutletAdapter<S>> getOutletAdapter<S, T extends ChannelFormat<S>>(
    OutletAdapter<S>? adapter) {
  if (adapter == null) {
    return Result.error(Exception("The adapter is null"));
  }
  return Result.ok(adapter);
}

/// "Unwraps" the nullable stream adapter
///
/// {@macro non_null_members}
Result<StreamAdapter> getStreamAdapter(StreamAdapter? repo) {
  if (repo == null) {
    return Result.error(Exception("The adapter is null"));
  }
  return Result.ok(repo);
}
