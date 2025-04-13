part of '../lsl_plugin.dart';

typedef Sample<T> = (List<T>, double);
typedef Chunk<T> = List<Sample<T>>;
typedef TimeOffset = (double collectiontime, double offset);
