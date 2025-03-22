import 'dart:developer';
import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/streams/resolved_stream.dart';
import 'package:lsl_plugin/src/adapters/streams/stream_adapter.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/errors.dart';
import 'package:lsl_plugin/src/utils/stream_info.dart';
import 'package:lsl_plugin/src/utils/unit.dart';

class AsyncStreamAdapter implements StreamAdapter {
  final Map<String, ResolvedStream> _resolvedStreams = {};

  AsyncStreamAdapter();

  @override
  Future<List<ResolvedStreamHandle>> resolveStreams(double waitTime) async {
    /// The resolve function can take up to several seconds so we delegate it to a helper isolate
    /// Otherwise, an app using this function will feel janky
    final List<ResolvedStream> streams = await Isolate.run(() {
      // Arbitrary buffer size
      const bufferSize = 1024;

      // Allocate the memory needed on the heap
      Pointer<lsl_streaminfo> buffer = malloc.allocate<lsl_streaminfo>(
          bufferSize * sizeOf<Pointer<lsl_streaminfo_struct_>>());

      // Resolve all streams on the network and write them to the buffer.
      // Return the number of streams found
      var numStreams =
          lsl.bindings.lsl_resolve_all(buffer, bufferSize, waitTime);

      // Create ResolvedStream objects for each stream
      final List<ResolvedStream> list = [];
      for (var i = 0; i < numStreams; i++) {
        switch (getStreamInfo(buffer[i])) {
          case Ok(value: var info):
            list.add(ResolvedStream(buffer[i], info));
            break;
          case Error(error: var e):
            log("$e");
        }
      }
      return list;
    });

    /// We can not modify _resolvedStreams inside the body of the isolate helper
    /// Therefore, we must perform a loop again outside it.
    for (var stream in streams) {
      final uid = stream.info.uid;
      // If it exists, use the uid as the key
      if (uid != null && uid != "") {
        _resolvedStreams[uid] = stream;
      } else {
        // TODO: Should I handle this differently perhaps?
        // Otherwise don't register the stream and free the allocated memory
        lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
        malloc.free(stream.streamInfoPointer);
      }
    }

    return _getStreamHandles();
  }

  Result<Unit> destroyStreams() {
    try {
      _resolvedStreams.forEach((_, stream) {
        lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
      });
      _resolvedStreams.clear();

      return Result.ok(unit);
    } catch (e) {
      return unexpectedError("$e");
    }
  }

  /// Gets the handles for the currently saved streams
  List<ResolvedStreamHandle> _getStreamHandles() {
    return _resolvedStreams.entries.map((entry) {
      return ResolvedStreamHandle(entry.key, entry.value.info);
    }).toList();
  }

  // TODO: createInlet
  // Consider removing from the stored handles as refreshing may destroy the stream infos
}
