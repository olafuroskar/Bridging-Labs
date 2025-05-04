import 'package:lsl_bindings/lsl_bindings.dart';
import 'package:lsl_flutter/lsl_flutter.dart';

/// Encapsulates resolved streams with their pointers
///
/// We use a constant class for passing back the id, instead of simply returning an int
/// to emphasize the immutability of the id.
class ResolvedStream {
  final lsl_streaminfo streamInfoPointer;
  final StreamInfo info;
  ResolvedStream(this.streamInfoPointer, this.info);
}
