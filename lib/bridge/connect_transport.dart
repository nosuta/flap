import 'dart:async';
import 'package:connectrpc/connect.dart';
import 'package:flap/bridge/bridge.dart';
import 'package:flap/pb/message.pb.dart' as pb;

class BridgeTransport implements Transport {
  final Bridge _bridge;

  BridgeTransport(this._bridge);

  @override
  Future<UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    Spec<I, O> spec,
    I input, [
    CallOptions? options,
  ]) async {
    final payload = (input as dynamic).writeToBuffer();
    final req = pb.Request(
      connectRequest: pb.ConnectRequest(path: spec.procedure, payload: payload),
    );

    final resp = await _bridge.rpc(req);
    if (resp.hasError()) {
      throw ConnectException(
        Code.values.firstWhere(
          (c) => c.value == resp.error.code,
          orElse: () => Code.unknown,
        ),
        resp.error.message,
      );
    }

    if (!resp.hasConnectResponse()) {
      throw ConnectException(Code.internal, 'Missing ConnectResponse');
    }

    final output = spec.outputFactory();
    (output as dynamic).mergeFromBuffer(resp.connectResponse.payload);

    return UnaryResponse(spec, Headers(), output, Headers());
  }

  @override
  Future<StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    Spec<I, O> spec,
    Stream<I> input, [
    CallOptions? options,
  ]) async {
    final controller = StreamController<O>();

    input.listen((i) async {
      final payload = (i as dynamic).writeToBuffer();
      final req = pb.Request(
        connectRequest: pb.ConnectRequest(
          path: spec.procedure,
          payload: payload,
        ),
      );

      try {
        final stream = await _bridge.rpcStream(req);
        await for (final resp in stream) {
          if (resp.hasError()) {
            controller.addError(
              ConnectException(
                Code.values.firstWhere(
                  (c) => c.value == resp.error.code,
                  orElse: () => Code.unknown,
                ),
                resp.error.message,
              ),
            );
            continue;
          }
          if (resp.hasConnectResponse()) {
            final output = spec.outputFactory();
            (output as dynamic).mergeFromBuffer(resp.connectResponse.payload);
            controller.add(output);
          }
        }
        await controller.close();
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    });

    return StreamResponse(spec, Headers(), controller.stream, Headers());
  }
}
