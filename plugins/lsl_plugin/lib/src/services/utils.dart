import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/utils/result.dart';

/// "Unwraps" the nullable outlet repository
///
/// {@macro non_null_members}
Result<OutletRepository<S>> getRepository<S, T extends ChannelFormat<S>>(
    OutletRepository<S>? repo) {
  if (repo == null) {
    return Result.error(Exception("The repository is null"));
  }
  return Result.ok(repo);
}
