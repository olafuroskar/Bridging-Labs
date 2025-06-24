part of '../../lsl_flutter.dart';

class Outlet<S> {
  StreamInfo<S> streamInfo;
  int chunkSize;
  int maxBuffered;

  Outlet(this.streamInfo, [this.chunkSize = 0, this.maxBuffered = 360]);
}
