part of '../../../lsl_flutter.dart';

/// Encapsulates the id of a resolved stream
///
/// Does not contain any reference to native pointers. A user can pass an instance of
/// this class to the stream manager to create an inlet (if the stream still exists).
class ResolvedStreamHandle {
  /// Unique identifier for the handle
  final String id;

  /// Stream metadata
  final StreamInfo info;

  /// Creates a [ResolvedStreamHandle] instance
  const ResolvedStreamHandle(this.id, this.info);
}
