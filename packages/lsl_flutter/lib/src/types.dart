part of '../lsl_flutter.dart';

/// A tuple representing a sample. The first property is the data,
/// where the length of the list represents the number of channels.
/// The second property is the timestamp.
typedef Sample<T> = (List<T>, double);

/// List representing a chunk, which is just a list of samples.
typedef Chunk<T> = List<Sample<T>>;

/// A tuple holding the timestamp when the offset was collected,
/// and the offset itself.
typedef TimeOffset = (double collectiontime, double offset);
