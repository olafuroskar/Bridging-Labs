import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/lsl_bindings_generated.dart';

/// Encapsulates resolved streams with their pointers
///
/// We use a constant class for passing back the id, instead of simply returning an int
/// to emphasize the immutability of the id.
class ResolvedStream<S> {
  final lsl_streaminfo streamInfoPointer;
  final StreamInfo<S> info;
  ResolvedStream(this.streamInfoPointer, this.info);
}
