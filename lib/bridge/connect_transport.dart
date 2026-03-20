import 'dart:async';
import 'package:flap/bridge/bridge.dart';
import 'package:flap/pb/message.pb.dart' as pb;

class BridgeTransport {
  final Bridge bridge;
  BridgeTransport(this.bridge);

  Future<O> unary<I extends Object, O extends Object>(
    String path,
    I input,
    O Function() outputFactory,
  ) async {
    final payload = (input as dynamic).writeToBuffer();
    final req = pb.Request(
      connectRequest: pb.ConnectRequest(path: path, payload: payload),
    );

    final resp = await bridge.rpc(req);
    if (resp.hasError()) {
      throw Exception('[${resp.error.code}] ${resp.error.message}');
    }
    if (!resp.hasConnectResponse()) {
      throw Exception('Missing ConnectResponse');
    }

    final output = outputFactory();
    (output as dynamic).mergeFromBuffer(resp.connectResponse.payload);
    return output;
  }

  Stream<O> stream<I extends Object, O extends Object>(
    String path,
    I input,
    O Function() outputFactory,
  ) async* {
    final payload = (input as dynamic).writeToBuffer();
    final req = pb.Request(
      connectRequest: pb.ConnectRequest(path: path, payload: payload),
    );

    final respStream = await bridge.rpcStream(req);
    await for (final resp in respStream) {
      if (resp.hasError()) {
        throw Exception('[${resp.error.code}] ${resp.error.message}');
      }
      if (resp.hasConnectResponse()) {
        final output = outputFactory();
        (output as dynamic).mergeFromBuffer(resp.connectResponse.payload);
        yield output;
      }
    }
  }
}
