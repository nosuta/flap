import 'package:flap/pb/nostr.pb.dart';
import 'package:flap/pb/nostr.flap.dart';
import 'package:flap/helpers/nip07.dart';

class NostrReverseRpcImpl extends NostrReverseRpc {
  @override
  Future<Nip07SignEventResponse> nip07SignEvent(Nip07SignEventRequest req) async {
    String? signedEvent;
    try { 
      signedEvent = await Nip07.signEvent(req.event);
    } catch(e) {
      signedEvent = null;
    }
    return Nip07SignEventResponse(signedEvent: signedEvent);
  }
}