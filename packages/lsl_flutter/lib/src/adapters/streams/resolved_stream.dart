import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';

/// Encapsulates resolved streams with their pointers
///
/// We use a constant class for passing back the id, instead of simply returning an int
/// to emphasize the immutability of the id.
class ResolvedStream {
  /// Reference to the native stream info object
  final lsl_streaminfo streamInfoPointer;

  /// The Dart StreamInfo object corresponding to [streamInfoPointer]
  final StreamInfo info;

  /// Creates a [ResolvedStream] instance
  ResolvedStream(this.streamInfoPointer, this.info);
}
