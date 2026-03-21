// Code as template. DO NOT EDIT.

import 'dart:async';

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'package:logging/logging.dart';

import 'package:flap/pb/core.pb.dart';
import 'package:flap/version/go_build_version.dart';
import 'package:flap/app_encryption_key/app_encryption_key.dart';

class Bridge extends ChangeNotifier {
  static Bridge? _instance;
  Bridge._() {
    _log.info('web bridge instantiate');
    final w = web.Worker('worker.js?v=${GoBuildVersion.version}'.toJS);
    if (!w.isDefinedAndNotNull) {
      _log.severe('worker is not defined or null');
    }
    w.onmessage = _onGlobalMessage.toJS;

    _worker = w;
    _pushController = StreamController<Push>.broadcast();
  }
  factory Bridge() {
    _instance ??= Bridge._();
    return _instance!;
  }

  bool get ready => _ready;
  Stream<Push> get push => _pushController.stream;

  final _log = Logger('Bridge Web');
  late final web.Worker _worker;
  late final StreamController<Push> _pushController;

  Int64 _port = Int64(0);
  bool _ready = false;
  bool _fatal = false;

  @override
  void dispose() {
    _pushController.close();
    _worker.terminate();
    super.dispose();
  }

  Int64 _nextPort() {
    return _port++;
  }

  void _onGlobalMessage(web.MessageEvent message) {
    _log.info('_onGlobalMessage: ${message.data}');
    if (message.isUndefinedOrNull || message.data.isUndefinedOrNull) {
      _log.shout('unsupported system (see browser logs)');
      _fatal = true;
      return;
    }
    final b = (message.data as JSUint8Array?)?.toDart;
    if (b == null) {
      _log.shout('missing message');
      _fatal = true;
      return;
    }
    final resp = Response.fromBuffer(b);
    if (resp.hasError()) {
      _log.shout('bridge global error: ${resp.error.message}');
      _fatal = true;
      return;
    }

    if (resp.hasDone()) {
      AppEncryptionKey.key().then((key) {
        _log.info('app encryption key: $key');
        final req = Request(init: Init(appEncryptionKey: key));
        rpcUnsafe(req).then((resp) {
          _log.info('bridge global init response');
          if (resp.hasError()) {
            _log.shout('bridge global error: ${resp.error.message}');
            _fatal = true;
            return;
          }
          if (resp.hasDone()) {
            _log.info('worker is ready');
            _ready = true;
            notifyListeners();
            return;
          }
          _log.shout('unknown fatal situation');
          _fatal = true;
        });
      });
      return;
    } else if (resp.hasPush()) {
      _pushController.sink.add(resp.push);
      return;
    } 
    _log.shout('unknown fatal situation');
    _fatal = true;
  }

  Future<void> _waitReady() async {
    const int waitMilliseconds = 100;
    const int waitCount = 100;
    int count = 0;
    await Future.doWhile(() async {
      if (_fatal) {
        throw Exception('failed to launch root worker');
      }
      if (ready) {
        return false;
      }
      if (count > waitCount) {
        throw Exception(
          'worker timeout: ${waitCount * waitMilliseconds * 0.001}s',
        );
      }
      await Future.delayed(Duration(milliseconds: waitMilliseconds));
      count++;
      return true;
    });
  }

  Future<Response> rpcUnsafe(Request req) async {
    final comp = Completer<Response>();
    req.port = _nextPort();
    final ch = web.MessageChannel();

    ch.port1.onmessage = ((web.MessageEvent message) {
      if (comp.isCompleted) {
        _log.severe('port is used after completed: $req.port');
        ch.port2.close();
        ch.port1.close();
        return;
      }
      final b = (message.data as JSUint8Array?)?.toDart;
      if (b != null) {
        final resp = Response.fromBuffer(b);
        if (resp.hasError()) {
          comp.completeError(
            'response error (${resp.error.code}): ${resp.error.message}',
          );
        } else {
          comp.complete(resp);
        }
      } else {
        comp.completeError('rpc response data is null');
      }
      ch.port2.close();
      ch.port1.close();
    }).toJS;

    final buf = req.writeToBuffer().toJS;
    final m = <JSObject>{ch.port2, buf}.jsify() as JSArray;
    final t =
        <JSObject>{
              ch.port2,
              buf.getProperty('buffer'.toJS) as JSArrayBuffer,
            }.jsify()
            as JSArray;
    _log.info('rpc post message');
    _worker.postMessage(m, t);
    return comp.future;
  }

  Future<Response> rpc(Request req) async {
    await _waitReady();

    return await rpcUnsafe(req);
  }

  Future<Stream<Response>> rpcStream(Request req) async {
    await _waitReady();

    final controller = StreamController<Response>();
    final port = _nextPort();
    _log.info('rpc stream: $port');
    req.port = port;
    final ch = web.MessageChannel();

    ch.port1.onmessage = ((web.MessageEvent message) {
      // log.info('prc stream: on message from $port');
      final b = (message.data as JSUint8Array?)?.toDart;
      if (b != null) {
        final resp = Response.fromBuffer(b);
        if (resp.hasError()) {
          _log.severe(resp.error.message, null, StackTrace.current);
          return;
        }
        if (resp.hasDone()) {
          ch.port2.close();
          ch.port1.close();
          controller.close();
          _log.info('rpc stream: done $port');
          return;
        }
        controller.sink.add(resp);
      }
    }).toJS;

    controller.onListen = () {
      _log.info('rpc stream: on listen to $port');
    };

    controller.onCancel = () async {
      _log.info('rpc stream: on cancel $port');
      final req = Request(cancel: Cancel(port: port));
      final resp = await rpc(req);
      if (resp.hasError()) {
        _log.severe('rpc stream eror on cancel: ${resp.error.message}');
      }
    };

    final buf = req.writeToBuffer().toJS;
    final m = <JSObject>{ch.port2, buf}.jsify() as JSArray;
    final t =
        <JSObject>{
              ch.port2,
              buf.getProperty('buffer'.toJS) as JSArrayBuffer,
            }.jsify()
            as JSArray;
    _log.info('rpc stream: post message to $port');
    _worker.postMessage(m, t);

    return controller.stream;
  }
}
