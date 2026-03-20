import 'dart:async';
import 'package:flap/bridge/bridge.dart';
import 'package:flap/pb/core.pb.dart' as pb;

class Transport {
  final Bridge bridge;
  Transport(this.bridge);

  Future<O> unary<I extends Object, O extends Object>(
    String path,
    I input,
    O Function() outputFactory,
  ) async {
    final payload = (input as dynamic).writeToBuffer();
    final req = pb.Request(
      rpcRequest: pb.RpcRequest(path: path, payload: payload),
    );

    final resp = await bridge.rpc(req);
    if (resp.hasError()) {
      throw Exception('[${resp.error.code}] ${resp.error.message}');
    }
    if (!resp.hasRpcResponse()) {
      throw Exception('Missing RpcResponse');
    }

    final output = outputFactory();
    (output as dynamic).mergeFromBuffer(resp.rpcResponse.payload);
    return output;
  }

  Stream<O> stream<I extends Object, O extends Object>(
    String path,
    I input,
    O Function() outputFactory,
  ) async* {
    final payload = (input as dynamic).writeToBuffer();
    final req = pb.Request(
      rpcRequest: pb.RpcRequest(path: path, payload: payload),
    );

    final respStream = await bridge.rpcStream(req);
    await for (final resp in respStream) {
      if (resp.hasError()) {
        throw Exception('[${resp.error.code}] ${resp.error.message}');
      }
      if (resp.hasRpcResponse()) {
        final output = outputFactory();
        (output as dynamic).mergeFromBuffer(resp.rpcResponse.payload);
        yield output;
      }
    }
  }
}
