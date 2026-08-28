// Tests for the pure FFI byte-conversion helpers extracted from the native
// bridge. These exercise the Dart<->Go memory contract without a native
// library: Dart allocates the request container, reads back response
// containers and frees the C heap exactly like the bridge does.
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:godash/bridge/native_bytes.dart';
import 'package:godash/pb/core.pb.dart';
import 'package:godash/bridge/native_library.g.dart';

/// Allocates a BytesContainer via the helper under test (same shape the Go
/// side receives) and returns it plus its message bytes.
Pointer<BytesContainer> makeContainer(List<int> bytes) {
  return bytesToBytesContainerPointer(Uint8List.fromList(bytes));
}

/// Frees a request container the same way the Go side does (message first,
/// then the container struct).
void freeContainer(Pointer<BytesContainer> c) {
  malloc.free(c.ref.message.cast<Uint8>());
  malloc.free(c);
}

void main() {
  test('bytesToBytesContainerPointer roundtrip', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    final c = makeContainer(bytes);
    expect(c.ref.size, bytes.length);
    final back = c.ref.message.cast<Uint8>().asTypedList(bytes.length);
    expect(back, bytes);
    freeContainer(c);
  });

  test('bytesToBytesContainerPointer with empty payload', () {
    final c = makeContainer([]);
    expect(c.ref.size, 0);
    // The message pointer may be null for zero-length payloads; the Go side
    // only ever reads size bytes from it, so either value is safe as long as
    // reading is guarded by size == 0.
    if (c.ref.message.address != 0) {
      final back = c.ref.message.cast<Uint8>().asTypedList(0);
      expect(back, isEmpty);
    }
    freeContainer(c);
  });

  test('bytesToBytesContainerPointer with 1 MiB payload', () {
    final bytes = Uint8List.fromList(
      List.generate(1 << 20, (i) => i & 0xFF),
    );
    final c = makeContainer(bytes);
    expect(c.ref.size, bytes.length);
    final back = c.ref.message.cast<Uint8>().asTypedList(bytes.length);
    expect(back, bytes);
    freeContainer(c);
  });

  test('pointerAddressToBytes roundtrip', () {
    final bytes = Uint8List.fromList([9, 8, 7, 6, 5, 4, 3, 2, 1]);
    final c = makeContainer(bytes);
    final (got, freeLater) = pointerAddressToBytes(c.address);
    expect(got, bytes);
    // The container struct is already freed by the helper; the message
    // buffer must be freed by the caller (this is the bridge contract).
    expect(freeLater.address, isNot(0));
    malloc.free(freeLater);
  });

  test('pointerAddressToBytes throws on null message', () {
    final c = calloc<BytesContainer>();
    c.ref.size = 0;
    c.ref.message = nullptr;
    // The helper frees the container struct itself before throwing.
    expect(() => pointerAddressToBytes(c.address), throwsException);
  });

  test('responseFromPointerAddress roundtrip (rpc_response)', () {
    final want = Response(
      rpcResponse: RpcResponse(payload: [1, 2, 3, 4, 5]),
    );
    final c = makeContainer(want.writeToBuffer());
    // Capture the message pointer before the call: the container struct is
    // freed inside pointerAddressToBytes, so reading c.ref afterwards would
    // touch freed memory.
    final got = responseFromPointerAddress(c.address);
    expect(got.hasRpcResponse(), isTrue);
    expect(got.rpcResponse.payload, want.rpcResponse.payload);
  });

  test('responseFromPointerAddress roundtrip (error)', () {
    final want = Response(
      error: Error(code: 404, message: 'RPC path not found'),
    );
    final c = makeContainer(want.writeToBuffer());
    final got = responseFromPointerAddress(c.address);
    expect(got.hasError(), isTrue);
    expect(got.error.code, 404);
    expect(got.error.message, 'RPC path not found');
  });

  test('responseFromPointerAddress roundtrip (push)', () {
    final want = Response(
      push: Push(
        type: 'tick',
        payload: [42],
        reversePort: Int64(777),
      ),
    );
    final c = makeContainer(want.writeToBuffer());
    final got = responseFromPointerAddress(c.address);
    expect(got.hasPush(), isTrue);
    expect(got.push.type, 'tick');
    expect(got.push.payload, want.push.payload);
    expect(got.push.reversePort, Int64(777));
  });

  test('stringFromPointerAddress roundtrip', () {
    for (final s in ['hello', '', 'こんにちは', '🙂👍']) {
      final c = makeContainer(utf8.encode(s));
      // The message buffer is freed inside stringFromPointerAddress.
      expect(stringFromPointerAddress(c.address), s);
    }
  });
}
