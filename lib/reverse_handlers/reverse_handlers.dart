import 'package:flap/pb/nostr.pb.dart';
import 'package:flap/pb/nostr.flap.dart';

class DeviceLocaleHandler extends DeviceReverseServiceHandler {
  @override
  Future<GetDeviceLocaleResponse> getDeviceLocale(GetDeviceLocaleRequest req) async {
    return GetDeviceLocaleResponse(locale: 'ja_JP');
  }
}