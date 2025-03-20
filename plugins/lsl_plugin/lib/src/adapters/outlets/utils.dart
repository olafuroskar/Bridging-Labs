import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

Result<lsl_outlet> createOutlet<S>(
    Outlet<S> outlet, ChannelFormat<S> channelFormat) {
  try {
    // Required on Android, TODO: Explain more...
    lsl.multicastLock.acquire();

    final streamInfo = lsl.bindings.lsl_create_streaminfo(
        outlet.streamInfo.name.toNativeUtf8().cast<Char>(),
        outlet.streamInfo.type.toNativeUtf8().cast<Char>(),
        outlet.streamInfo.channelCount,
        outlet.streamInfo.nominalSRate,
        channelFormat.nativeChannelFormat,
        outlet.streamInfo.sourceId.toNativeUtf8().cast<Char>());

    return Result.ok(lsl.bindings
        .lsl_create_outlet(streamInfo, outlet.chunkSize, outlet.maxBuffered));
  } catch (e) {
    return unexpectedError("$e");
  }
}

Result<Unit> destroyOutlet(lsl_outlet? outlet) {
  if (outlet == null) {
    return Result.error(Exception("The native outlet is null"));
  }
  try {
    lsl.bindings.lsl_destroy_outlet(outlet);
    lsl.multicastLock.release();
    return Result.ok(unit);
  } catch (e) {
    return unexpectedError("$e");
  }
}

/// "Unwraps" the nullable native outlet
///
/// {@template non_null_members}
/// The Dart compiler can only infer that variables are not null on local variables
/// so null checks on member variable in e.g. the reHH
/// {@endtemplate}
lsl_outlet getOutlet(lsl_outlet? outlet) {
  if (outlet == null) {
    throw Exception("The native outlet is null");
  }
  return outlet;
}
