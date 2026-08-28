// Code as template. DO NOT EDIT.

/// Pure FFI byte-conversion helpers shared by the native [Bridge].
///
/// These helpers own the cross-heap memory contract between Dart and Go:
/// - Requests: Dart copies the serialized envelope into a malloc'd
///   [BytesContainer]; the Go side frees both the message buffer and the
///   container before dispatching (see generated `go/main.go`).
/// - Responses/pushes: Go allocates via `BytesToPointerAddress`; Dart reads
///   the message and frees the container immediately, then frees the message
///   pointer after parsing (see [pointerAddressToBytes]).
library;

import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'package:godash/pb/core.pb.dart';

import 'native_library.g.dart';

/// Allocates a [BytesContainer] on the C heap holding a copy of [bytes].
Pointer<BytesContainer> bytesToBytesContainerPointer(Uint8List bytes) {
  final n = bytes.length;
  final bytesHeap = malloc<Uint8>(n);
  bytesHeap.asTypedList(n).setRange(0, n, bytes);
  final payload = calloc<BytesContainer>()
    ..ref.size = n
    ..ref.message = bytesHeap.cast<Void>();
  return payload;
}

/// Reads the [BytesContainer] at [address] into a Dart-owned [Uint8List].
///
/// The container struct is freed immediately. The message buffer is returned
/// as [freeLater] and must be freed by the caller once the bytes have been
/// consumed (e.g. after parsing the protobuf envelope).
(Uint8List bytes, Pointer<Void> freeLater) pointerAddressToBytes(int address) {
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

/// Parses a [Response] delivered as a pointer address and frees the C heap.
Response responseFromPointerAddress(int address) {
  final (b, freeLater) = pointerAddressToBytes(address);
  final resp = Response.fromBuffer(b);
  malloc.free(freeLater);
  return resp;
}

/// Decodes a UTF-8 string delivered as a pointer address and frees the C heap.
String stringFromPointerAddress(int address) {
  final (b, freeLater) = pointerAddressToBytes(address);
  final str = utf8.decode(b);
  malloc.free(freeLater);
  return str;
}
