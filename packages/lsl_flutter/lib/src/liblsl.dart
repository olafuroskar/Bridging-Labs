import 'package:carp_multicast_lock/carp_multicast_lock.dart';
import 'package:lsl_bindings/lsl_bindings.dart';

/// A class encapsulating the bindings to the native functions in [_dylib], as well as multicast lock for Android
///
/// This is an interface for testing purposes
class Lsl {
  /// {@macro bindings}
  static final Lsl _singleton = Lsl._internal();

  static LslBindings _bindings = lslBindings;
  static MulticastLock _multicastLock = MulticastLock();

  /// A set of all active outlets using [Lsl]
  static Set<String> activeOutlets = {};

  /// Initialises an [Lsl] singleton
  factory Lsl() {
    return _singleton;
  }

  /// Set the [LslBindings] instance in use
  static void setBindings(LslBindings bindings) {
    _bindings = bindings;
  }

  /// Set the [MulticastLock] instance in use
  static void setMulticastLock(MulticastLock multicastLock) {
    _multicastLock = multicastLock;
  }

  /// Acquire a multicast lock. (Android only)
  ///
  /// [name] The name of the stream that the lock is being acquired for
  ///
  /// Release using [releaseMulticastLock]
  ///
  /// LSL uses UDP multicast for its stream discovery process. Android by default blocks
  /// the processing of multicast packets. However, they permit the processing of them
  /// if a multicast lock is explicitly acquired.
  /// Acquiring the lock more than once has no effect.
  acquireMulticastLock(String name) async {
    await _multicastLock.acquireMulticastLock();
    activeOutlets.add(name);
  }

  /// Release the multicast lock acquired in [acquireMulticastLock] (Android only)
  ///
  /// [name] The name of the stream that the lock is being released for
  ///
  /// Once multicast capability is no longer needed it should be released.
  releaseMulticastLock(String name) {
    activeOutlets.remove(name);

    /// Only release the multicast lock of no other streams are active.
    if (activeOutlets.isEmpty) {
      _multicastLock.releaseMulticastLock();
    }
  }

  /// Get the [LslBindings] instance in use
  LslBindings get bindings => _bindings;

  Lsl._internal();
}

/// The global [Lsl] object used in the adapters.
final lsl = Lsl();
