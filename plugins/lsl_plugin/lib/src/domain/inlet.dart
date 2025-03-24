part of '../../lsl_plugin.dart';

class Inlet<S> {
  StreamInfo<S> streamInfo;
  int maxBufLen;
  int maxChunkLen;
  bool recover;

  Inlet(this.streamInfo,
      [this.maxBufLen = 360, this.maxChunkLen = 0, this.recover = true]);
}
