import 'package:lsl_plugin/lsl_plugin.dart';
import 'package:lsl_plugin/src/utils/result.dart';

Result<T> sampleTypeChannelFormatMismatchError<T>(
    String sampleType, ChannelFormat channelFormat) {
  return Result.error(Exception(
      "The type of sample ($sampleType) and the channel format (${channelFormat.value.toString()}) are not compatible"));
}

Result<T> unexpectedError<T>(String e) {
  return Result.error(Exception("An unexpected error was encountered: $e"));
}
