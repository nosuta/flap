
import 'native_internal_platform_interface.dart';

class NativeInternal {
  Future<String?> getPlatformVersion() {
    return NativeInternalPlatform.instance.getPlatformVersion();
  }
}
