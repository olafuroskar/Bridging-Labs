import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';
import 'package:lsl_flutter/src/adapters/inlets/inlets.dart';
import 'package:lsl_flutter/src/adapters/streams/resolved_stream.dart';
import 'package:lsl_flutter/src/adapters/utils.dart';
import 'package:lsl_flutter/src/liblsl.dart';
import 'package:lsl_flutter/src/utils/stream_info.dart';

/// An adapter for stream resolving
class StreamAdapter {
  /// A map of the currently resolved streams
  final Map<String, ResolvedStream> _resolvedStreams = {};

  /// Arbitrary buffer size for stream resolving
  final bufferSize = 1024;

  /// Creates a [StreamAdapter] instance
  StreamAdapter();

  /// {@template resolve_all}
  /// Resolve all streams on the network.
  ///
  /// This function returns all currently available streams from any outlet on the network.
  /// The network is usually the subnet specified at the local router, but may also include a multicast
  /// group of machines (given that the network supports it), or a list of hostnames.
  ///
  /// [timeout] The waiting time for the operation, in seconds, to search for streams.
  /// The recommended wait time is 1 second (or 2 for a busy and large recording operation).
  /// If this is too short (<0.5s) only a subset (or none) of the outlets that are present on
  /// the network may be returned.
  /// {@endtemplate}
  void resolveAllStreams(double timeout) {
    /// Clear the resolved streams before re-resolving
    destroyStreams();

    // Allocate the memory needed on the heap
    Pointer<lsl_streaminfo> buffer =
        malloc.allocate<lsl_streaminfo>(bufferSize * sizeOf<lsl_streaminfo>());

    // Resolve all streams on the network and write them to the buffer.
    // Return the number of streams found
    var numStreams = lsl.bindings.lsl_resolve_all(buffer, bufferSize, timeout);

    checkErrorValue(numStreams);

    _storeStreams(buffer, numStreams);

    malloc.free(buffer);
  }

  /// {@template resolve_prop}
  /// Resolve all streams with a given value for a property.
  ///
  /// If the goal is to resolve a specific stream, this method is preferred over resolving all streams
  /// and then selecting the desired one.
  ///
  /// The stream_info's returned by the resolver are only short versions that do not include
  /// the lsl_get_desc() field (which can be arbitrarily big). To obtain the full stream information
  /// you need to call [InletManager.getStreamInfo] on the inlet after you have created one.
  /// [prop] The streaminfo property that should have a specific value (`"name"`, `"type"`,
  /// `"source_id"`, or, e.g., `"desc/manufaturer"` if present).
  /// [value] The string value that the property should have (e.g., "EEG" as the type).
  /// [minimum] Return at least this number of streams.
  /// [timeout] Optionally a timeout of the operation, in seconds (default: no timeout).
  /// If the timeout expires, less than the desired number of streams (possibly none) will be returned.
  /// {@endtemplate}
  void resolveStreamsByProp(
      double timeout, String prop, String value, int minimum) {
    /// Clear the resolved streams before re-resolving
    destroyStreams();

    // Allocate the memory needed on the heap
    Pointer<lsl_streaminfo> buffer =
        malloc.allocate<lsl_streaminfo>(bufferSize * sizeOf<lsl_streaminfo>());

    // Resolve streams with the given prop value on the network
    // Return the number of streams found
    var numStreams = lsl.bindings.lsl_resolve_byprop(
      buffer,
      bufferSize,
      prop.toNativeUtf8().cast<Char>(),
      value.toNativeUtf8().cast<Char>(),
      minimum,
      timeout,
    );

    checkErrorValue(numStreams);

    _storeStreams(buffer, numStreams);

    malloc.free(buffer);
  }

  /// {@template resolve_pred}
  /// Resolve all streams that match a given predicate.
  ///
  /// Advanced query that allows to impose more conditions on the retrieved streams;
  /// the given string is an [XPath 1.0 predicate](http://en.wikipedia.org/w/index.php?title=XPath_1.0)
  /// for the `<info>` node (omitting the surrounding []'s)
  ///
  /// The stream_info's returned by the resolver are only short versions that do not include
  /// the lsl_get_desc() field (which can be arbitrarily big). To obtain the full stream information
  /// you need to call [InletManager.getStreamInfo] on the inlet after you have created one.
  /// [pred] The predicate string, e.g.
  /// `name='BioSemi'` or `type='EEG' and starts-with(name,'BioSemi') and count(info/desc/channel)=32`
  /// [minimum] Return at least this number of streams.
  /// [timeout] Optionally a timeout of the operation, in seconds (default: no timeout).
  /// If the timeout expires, less than the desired number of streams (possibly none)
  /// will be returned.
  /// {@endtemplate}
  void resolveStreamsByPred(double timeout, String pred, int minimum) {
    /// Clear the resolved streams before re-resolving
    destroyStreams();

    // Allocate the memory needed on the heap
    Pointer<lsl_streaminfo> buffer =
        malloc.allocate<lsl_streaminfo>(bufferSize * sizeOf<lsl_streaminfo>());

    // Resolve streams by a given predicate
    // Return the number of streams found
    var numStreams = lsl.bindings.lsl_resolve_bypred(
      buffer,
      bufferSize,
      pred.toNativeUtf8().cast<Char>(),
      minimum,
      timeout,
    );

    checkErrorValue(numStreams);

    _storeStreams(buffer, numStreams);

    malloc.free(buffer);
  }

  /// {@template get_stream_handles}
  /// Gets all resolved stream handles
  /// {@endtemplate}
  List<ResolvedStreamHandle> getStreamHandles() {
    return _resolvedStreams.entries.map((entry) {
      return ResolvedStreamHandle(entry.key, entry.value.info);
    }).toList();
  }

  /// Creates an inlet from a given handle
  ///
  /// [handle] Handle containing the needed stream information to create an inlet.
  InletAdapter<S> createInlet<S>(ResolvedStreamHandle handle) {
    InletAdapter<S> inletAdapter;

    final stream = _resolvedStreams[handle.id];
    if (stream == null) throw Exception("Stream not found");

    if (S == int) {
      if (stream.info.channelFormat is! ChannelFormat<int>) {
        return throw Exception("The resolved stream is not of type int");
      }

      inletAdapter = InletAdapterFactory.createIntAdapterFromStream(
          Inlet(stream.info as StreamInfo<int>), stream) as InletAdapter<S>;
    } else if (S == double) {
      if (stream.info.channelFormat is! ChannelFormat<double>) {
        return throw Exception("The resolved stream is not of type double");
      }

      inletAdapter = InletAdapterFactory.createDoubleAdapterFromStream(
          Inlet(stream.info as StreamInfo<double>), stream) as InletAdapter<S>;
    } else if (S == String) {
      if (stream.info.channelFormat is! ChannelFormat<String>) {
        return throw Exception("The resolved stream is not of type String");
      }

      inletAdapter = InletAdapterFactory.createStringAdapterFromStream(
          Inlet(stream.info as StreamInfo<String>), stream) as InletAdapter<S>;
    } else {
      throw Exception("Unsupported type");
    }

    return inletAdapter;
  }

  /// {@template destroy_streams}
  /// Destroy all resolved stream information objects.
  /// {@endtemplate}
  void destroyStreams() {
    _resolvedStreams.forEach((_, stream) {
      lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
    });
    _resolvedStreams.clear();
  }

  void _storeStreams(Pointer<lsl_streaminfo> buffer, int numStreams) {
    for (var i = 0; i < numStreams; i++) {
      final info = extractStreamInfo(buffer[i]);
      switch (info.channelFormat) {
        case Int8ChannelFormat():
        case Int16ChannelFormat():
        case Int32ChannelFormat():
        case Int64ChannelFormat():
          final stream = ResolvedStream(buffer[i], info as StreamInfo<int>);

          _storeStream(stream);
          break;
        case Double64ChannelFormat():
        case Float32ChannelFormat():
          final stream = ResolvedStream(buffer[i], info as StreamInfo<double>);

          _storeStream(stream);
          break;
        case CftStringChannelFormat():
          final stream = ResolvedStream(buffer[i], info as StreamInfo<String>);

          _storeStream(stream);
          break;
      }
    }
  }

  void _storeStream(ResolvedStream stream) {
    final uid = stream.info.uid;
    if (uid != null && uid != "") {
      _resolvedStreams[uid] = stream;
    } else {
      // Otherwise don't register the stream and free the allocated memory
      lsl.bindings.lsl_destroy_streaminfo(stream.streamInfoPointer);
      malloc.free(stream.streamInfoPointer);
    }
  }
}
