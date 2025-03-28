import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/adapters/inlets/inlets.dart';
import 'package:lsl_plugin/src/adapters/streams/resolved_stream.dart';
import 'package:lsl_plugin/src/adapters/streams/stream_adapter.dart';
import 'package:lsl_plugin/src/liblsl.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';
import 'package:lsl_plugin/src/utils/stream_info.dart';

class AsyncStreamAdapter implements StreamAdapter {
  final Map<String, ResolvedStream<int>> _resolvedIntStreams = {};
  final Map<String, ResolvedStream<double>> _resolvedDoubleStreams = {};
  final Map<String, ResolvedStream<String>> _resolvedStringStreams = {};

  AsyncStreamAdapter();

  @override
  Future<void> resolveStreams(double waitTime) async {
    /// Clear the resolved streams before re-resolving
    _resolvedIntStreams.clear();
    _resolvedDoubleStreams.clear();
    _resolvedStringStreams.clear();

    /// The resolve function can take up to several seconds so we delegate it to a helper isolate
    /// Otherwise, an app using this function will feel janky
    final (
      List<ResolvedStream<int>>,
      List<ResolvedStream<double>>,
      List<ResolvedStream<String>>
    ) streams = await Isolate.run(() {
      // Arbitrary buffer size
      const bufferSize = 1024;

      // Allocate the memory needed on the heap
      Pointer<lsl_streaminfo> buffer = malloc
          .allocate<lsl_streaminfo>(bufferSize * sizeOf<lsl_streaminfo>());

      // Resolve all streams on the network and write them to the buffer.
      // Return the number of streams found
      var numStreams =
          lsl.bindings.lsl_resolve_all(buffer, bufferSize, waitTime);

      // Create ResolvedStream objects for each stream
      final List<ResolvedStream<int>> intList = [];
      final List<ResolvedStream<double>> doubleList = [];
      final List<ResolvedStream<String>> stringList = [];

      print("resolved: $numStreams");

      for (var i = 0; i < numStreams; i++) {
        final info = getStreamInfo(buffer[i]);
        switch (info.channelFormat) {
          case Int8ChannelFormat():
          case Int16ChannelFormat():
          case Int32ChannelFormat():
          case Int64ChannelFormat():
            intList
                .add(ResolvedStream<int>(buffer[i], info as StreamInfo<int>));
            break;
          case Double64ChannelFormat():
          case Float32ChannelFormat():
            doubleList.add(
                ResolvedStream<double>(buffer[i], info as StreamInfo<double>));
            break;
          case CftStringChannelFormat():
            stringList.add(
                ResolvedStream<String>(buffer[i], info as StreamInfo<String>));
        }
      }
      malloc.free(buffer);
      return (intList, doubleList, stringList);
    });

    print(streams);

    /// We can not modify _resolvedStreams inside the body of the isolate helper
    /// Therefore, we must perform a loop again outside it.
    for (var stream in streams.$1) {
      final uid = stream.info.uid;

      // If it exists, use the uid as the key
      if (uid != null && uid != "") {
        _resolvedIntStreams[uid] = stream;
      } else {
        // TODO: Should I handle this differently perhaps?
        // Otherwise don't register the stream and free the allocated memory
        lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
        malloc.free(stream.streamInfoPointer);
      }
    }

    for (var stream in streams.$2) {
      final uid = stream.info.uid;
      if (uid != null && uid != "") {
        _resolvedDoubleStreams[uid] = stream;
      } else {
        lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
        malloc.free(stream.streamInfoPointer);
      }
    }

    for (var stream in streams.$3) {
      final uid = stream.info.uid;
      if (uid != null && uid != "") {
        _resolvedStringStreams[uid] = stream;
      } else {
        lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
        malloc.free(stream.streamInfoPointer);
      }
    }
  }

  @override
  InletAdapter<S> createInlet<S>(ResolvedStreamHandle<S> handle) {
    InletAdapter<S> inletAdapter;

    if (S == int) {
      final stream = _resolvedIntStreams[handle.id];
      if (stream == null) throw Exception("Stream not found");

      inletAdapter = InletAdapterFactory.createIntAdapterFromStream(
          Inlet(stream.info), stream) as InletAdapter<S>;
    } else if (S == double) {
      final stream = _resolvedDoubleStreams[handle.id];
      if (stream == null) throw Exception("Stream not found");

      inletAdapter = InletAdapterFactory.createDoubleAdapterFromStream(
          Inlet(stream.info), stream) as InletAdapter<S>;
    } else if (S == String) {
      final stream = _resolvedStringStreams[handle.id];
      if (stream == null) throw Exception("Stream not found");

      inletAdapter = InletAdapterFactory.createStringAdapterFromStream(
          Inlet(stream.info), stream) as InletAdapter<S>;
    } else {
      throw Exception("Unsupported type");
    }

    return inletAdapter;
  }

  void destroyStreams() {
    _resolvedIntStreams.forEach((_, stream) {
      lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
    });
    _resolvedIntStreams.clear();

    _resolvedDoubleStreams.forEach((_, stream) {
      lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
    });
    _resolvedDoubleStreams.clear();

    _resolvedStringStreams.forEach((_, stream) {
      lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
    });
    _resolvedStringStreams.clear();
  }

  /// Gets the handles for the currently saved int streams
  @override
  List<ResolvedStreamHandle<int>> getIntStreamHandles() {
    return _resolvedIntStreams.entries.map((entry) {
      return ResolvedStreamHandle(entry.key, entry.value.info);
    }).toList();
  }

  /// Gets the handles for the currently saved double streams
  @override
  List<ResolvedStreamHandle<double>> getDoubleStreamHandles() {
    return _resolvedDoubleStreams.entries.map((entry) {
      return ResolvedStreamHandle(entry.key, entry.value.info);
    }).toList();
  }

  /// Gets the handles for the currently saved String streams
  @override
  List<ResolvedStreamHandle<String>> getStringStreamHandles() {
    return _resolvedStringStreams.entries.map((entry) {
      return ResolvedStreamHandle(entry.key, entry.value.info);
    }).toList();
  }
}
