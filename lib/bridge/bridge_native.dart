import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:ffi/ffi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flap/pb/core.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flap/pb/message.pb.dart';
import 'package:flap/app_encryption_key/app_encryption_key.dart';
import 'native_library.g.dart';

class Bridge extends ChangeNotifier {
  static Bridge? _instance;
  Bridge._() {
    _log.info('native bridge instantiate');
    _pushController = StreamController<Push>.broadcast();
    unawaited(_init());
  }
  factory Bridge() {
    _instance ??= Bridge._();
    return _instance!;
  }

  bool get ready => _ready;

  static const String _libName = String.fromEnvironment(
    'LIB_NAME',
    defaultValue: 'libflap',
  );
  final _log = Logger('Bridge Native');
  final _lib = NativeLibrary(_dylib());
  late final StreamController<Push> _pushController;
  bool _ready = false;
  bool _fatal = false;

  @override
  void dispose() {
    _pushController.close();
    super.dispose();
  }

  Stream<Push> get push => _pushController.stream;

  Future<void> _init() async {
    final ret = _lib.InitializeDartAPI(NativeApi.initializeApiDLData);
    if (ret != 0) {
      throw Exception(
        "failed to initialize Dart API due to a major version mismatch",
      );
    }
    final aek = await AppEncryptionKey.key();
    final pushPort = ReceivePort();
    pushPort.listen(_pushListener);
    final tmpDir = await getTemporaryDirectory();
    final supportDir = await getApplicationSupportDirectory();
    final documentsDir = await getApplicationDocumentsDirectory();
    final req = Request(
      init: Init(
        pushPort: Int64(pushPort.sendPort.nativePort),
        tempDir: tmpDir.absolute.path,
        supportDir: supportDir.absolute.path,
        documentsDir: documentsDir.absolute.path,
        appEncryptionKey: aek,
      ),
    );
    final resp = await rpc(req);
    if (resp.hasError()) {
      _fatal = true;
      throw Exception(resp.error.message);
    }

    _ready = true;
    notifyListeners();
  }

  Future<void> _waitReady() async {
    const int waitMilliseconds = 100;
    const int waitCount = 1000;
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

  Future<Response> rpc(Request req) async {
    final comp = Completer<Response>();
    final port = ReceivePort();
    final nativePort = port.sendPort.nativePort;
    _log.info('rpc: $nativePort');
    req.port = Int64(nativePort);

    port.listen((pointerAddr) {
      _log.info("rpc: receive pointer $pointerAddr on $nativePort");
      if (comp.isCompleted) {
        _log.severe('rpc: port $nativePort is used after completed');
        port.close();
        return;
      }
      try {
        final resp = pointerAddressToResponse(pointerAddr);
        if (resp.hasError()) {
          comp.completeError(
            'rpc: response error (${resp.error.code}) ${resp.error.message}',
          );
        } else {
          comp.complete(resp);
        }
      } catch (e) {
        comp.completeError(e);
      }
      _log.info('rpc: port $nativePort closed');
      port.close();
    });

    final buf = req.writeToBuffer();
    final payload = _bytesToBytesContainerPointer(buf);
    _lib.RPC(nativePort, payload);

    return comp.future;
  }

  Future<Stream<Response>> rpcStream(Request req) async {
    await _waitReady();

    final controller = StreamController<Response>();
    final port = ReceivePort();
    final nativePort = port.sendPort.nativePort;
    _log.info('rpc stream: $nativePort');
    req.port = Int64(nativePort);

    port.listen(
      (addr) {
        try {
          final resp = pointerAddressToResponse(addr);
          if (resp.hasError()) {
            _log.severe(
              'rpc stream: error on pointerAddressToResponse ${resp.error.message}',
              null,
              StackTrace.current,
            );
            return;
          }
          if (resp.hasDone()) {
            port.close();
            controller.close();
            _log.info('rpc stream: done $nativePort');
            return;
          }
          controller.sink.add(resp);
        } catch (e) {
          _log.warning('pointerAddressToResponse failed: $e');
        }
      },
      onError: (e) {
        _log.warning('rpc stream: listen error on $nativePort, $e');
        port.close();
        controller.close();
      },
      cancelOnError: true,
    );

    // controller.onListen = () {
    //   _log.info('rpc stream: on listen to $nativePort');
    // };

    controller.onCancel = () async {
      _log.info('rpc stream: on cancel $nativePort');
      final req = Request(cancel: Cancel(port: Int64(nativePort)));
      final resp = await rpc(req);
      if (resp.hasError()) {
        _log.severe('rpc stream: eror on cancel, ${resp.error.message}');
      }
    };

    final buf = req.writeToBuffer();
    final payload = _bytesToBytesContainerPointer(buf);
    _lib.RPC(nativePort, payload);

    return controller.stream;
  }

  Response pointerAddressToResponse(dynamic pointerAddr) {
    if (pointerAddr is! int) {
      throw Exception('pointerAddr must be a pointer address');
    }
    final (b, freeLater) = _pointerAddressToBytes(pointerAddr);
    final resp = Response.fromBuffer(b);
    malloc.free(freeLater);
    return resp;
  }

  Future<void> _pushListener(dynamic pointerAddr) async {
    if (pointerAddr is! int) {
      throw Exception('pointerAddr must be a pointer address');
    }
    final (b, freeLater) = _pointerAddressToBytes(pointerAddr);
    final resp = Response.fromBuffer(b);
    malloc.free(freeLater);
    if (!resp.hasPush()) {
      return;
    }
    _pushController.sink.add(resp.push);
  }

  Pointer<BytesContainer> _bytesToBytesContainerPointer(Uint8List bytes) {
    final n = bytes.length;
    final bytesHeap = malloc<Uint8>(n);
    bytesHeap.asTypedList(n).setRange(0, n, bytes);
    final payload = calloc<BytesContainer>()
      ..ref.size = n
      ..ref.message = bytesHeap.cast<Void>();
    return payload;
  }

  String pointerAddressToString(int address) {
    final (b, freeLater) = _pointerAddressToBytes(address);
    final str = utf8.decode(b);
    malloc.free(freeLater);
    return str;
  }

  /// freeLater must be free after converting bytes (C heap) to a Dart object
  (Uint8List bytes, Pointer<Void> freeLater) _pointerAddressToBytes(
    int address,
  ) {
    final p = Pointer<BytesContainer>.fromAddress(address);
    final pm = p.ref.message;
    if (pm.address == nullptr.address) {
      malloc.free(p);
      throw Exception('message.address is null');
    }
    final b = pm.cast<Uint8>().asTypedList(p.ref.size);
    final copy = Uint8List.fromList(b);
    malloc.free(p);
    return (copy, pm);
  }

  static DynamicLibrary _dylib() {
    if (Platform.isMacOS) {
      return DynamicLibrary.open("$_libName.dylib");
    }
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isAndroid) {
      return DynamicLibrary.open("$_libName.so");
    }
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }
}
