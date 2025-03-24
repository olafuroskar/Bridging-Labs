part of '../../../lsl_plugin.dart';

/// Encapsulates the id of a resolved stream
///
/// Does not contain any reference to native pointers. A user can pass an instance of
/// this class to the stream manager to create an inlet (if the stream still exists).
class ResolvedStreamHandle<S> {
  final String id;
  final StreamInfo<S> info;
  const ResolvedStreamHandle(this.id, this.info);
}
