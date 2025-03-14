import 'package:lsl_plugin/src/channel_formats/channel_format.dart';
import 'package:lsl_plugin/src/outlets/outlet.dart';
import 'package:lsl_plugin/src/utils/result.dart';

/// An interface for outlet builders
///
/// Channel format is not part of this interface because in order to provide a more
/// type safe way of defining the channel formats, they need to be split into three categories
/// See: [ChannelFormat]
abstract class OutletBuilder<T> {
  String get name;
  set name(String name);

  String get type;
  set type(String type);

  String get sourceId;
  set sourceId(String sourceId);

  int get channelCount;
  set channelCount(int channelCount);

  double get nominalSRate;
  set nominalSRate(double nominalSRate);

  int get chunkSize;
  set chunkSize(int chunkSize);

  int get maxBuffered;
  set maxBuffered(int maxBuffered);

  Result<Outlet<T>> build();
}
