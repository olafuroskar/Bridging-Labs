import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/outlets/outlet.dart';
import 'package:lsl_plugin/src/utils/result.dart';

abstract class OutletBuilder<T> {
  String get name;
  set name(String name);

  String get type;
  set type(String type);

  String get sourceId;
  set sourceId(String sourceId);

  ChannelFormat get channelFormat;
  set channelFormat(ChannelFormat channelFormat);

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
