
import 'muse_sdk_platform_interface.dart';

class MuseSdk {
  Future<String?> getPlatformVersion() {
    return MuseSdkPlatform.instance.getPlatformVersion();
  }
}
