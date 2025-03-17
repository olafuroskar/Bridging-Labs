part of '../../lsl_plugin.dart';

class Outlet<S> {
  StreamInfo<S> streamInfo;
  int chunkSize;
  int maxBuffered;

  Outlet(this.streamInfo, [this.chunkSize = 0, this.maxBuffered = 360]);
}
