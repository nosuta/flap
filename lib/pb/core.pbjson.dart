// This is a generated file - do not edit.
//
// Generated from core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use errorDescriptor instead')
const Error$json = {
  '1': 'Error',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Error`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List errorDescriptor = $convert.base64Decode(
    'CgVFcnJvchISCgRjb2RlGAEgASgFUgRjb2RlEhgKB21lc3NhZ2UYAiABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use cancelDescriptor instead')
const Cancel$json = {
  '1': 'Cancel',
  '2': [
    {'1': 'port', '3': 3, '4': 1, '5': 3, '10': 'port'},
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Cancel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelDescriptor = $convert.base64Decode(
    'CgZDYW5jZWwSEgoEcG9ydBgDIAEoA1IEcG9ydBISCgRjb2RlGAEgASgFUgRjb2RlEhgKB21lc3'
    'NhZ2UYAiABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use doneDescriptor instead')
const Done$json = {
  '1': 'Done',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `Done`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List doneDescriptor = $convert.base64Decode(
    'CgREb25lEhIKBGNvZGUYASABKAVSBGNvZGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZQ==');

@$core.Deprecated('Use initDescriptor instead')
const Init$json = {
  '1': 'Init',
  '2': [
    {'1': 'push_port', '3': 1, '4': 1, '5': 3, '10': 'pushPort'},
    {'1': 'temp_dir', '3': 2, '4': 1, '5': 9, '10': 'tempDir'},
    {'1': 'support_dir', '3': 3, '4': 1, '5': 9, '10': 'supportDir'},
    {'1': 'documents_dir', '3': 4, '4': 1, '5': 9, '10': 'documentsDir'},
    {
      '1': 'app_encryption_key',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'appEncryptionKey'
    },
  ],
};

/// Descriptor for `Init`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initDescriptor = $convert.base64Decode(
    'CgRJbml0EhsKCXB1c2hfcG9ydBgBIAEoA1IIcHVzaFBvcnQSGQoIdGVtcF9kaXIYAiABKAlSB3'
    'RlbXBEaXISHwoLc3VwcG9ydF9kaXIYAyABKAlSCnN1cHBvcnREaXISIwoNZG9jdW1lbnRzX2Rp'
    'chgEIAEoCVIMZG9jdW1lbnRzRGlyEiwKEmFwcF9lbmNyeXB0aW9uX2tleRgFIAEoCVIQYXBwRW'
    '5jcnlwdGlvbktleQ==');

@$core.Deprecated('Use reverseResponseDescriptor instead')
const ReverseResponse$json = {
  '1': 'ReverseResponse',
  '2': [
    {'1': 'reverse_port', '3': 1, '4': 1, '5': 3, '10': 'reversePort'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `ReverseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reverseResponseDescriptor = $convert.base64Decode(
    'Cg9SZXZlcnNlUmVzcG9uc2USIQoMcmV2ZXJzZV9wb3J0GAEgASgDUgtyZXZlcnNlUG9ydBIYCg'
    'dwYXlsb2FkGAIgASgMUgdwYXlsb2Fk');

@$core.Deprecated('Use requestDescriptor instead')
const Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'port', '3': 5, '4': 1, '5': 3, '10': 'port'},
    {
      '1': 'init',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pb.Init',
      '9': 0,
      '10': 'init'
    },
    {
      '1': 'cancel',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.pb.Cancel',
      '9': 0,
      '10': 'cancel'
    },
    {
      '1': 'rpc_request',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pb.RpcRequest',
      '9': 0,
      '10': 'rpcRequest'
    },
    {
      '1': 'reverse_response',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.pb.ReverseResponse',
      '9': 0,
      '10': 'reverseResponse'
    },
  ],
  '8': [
    {'1': 'requests'},
  ],
};

/// Descriptor for `Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDescriptor = $convert.base64Decode(
    'CgdSZXF1ZXN0EhIKBHBvcnQYBSABKANSBHBvcnQSHgoEaW5pdBgBIAEoCzIILnBiLkluaXRIAF'
    'IEaW5pdBIkCgZjYW5jZWwYBCABKAsyCi5wYi5DYW5jZWxIAFIGY2FuY2VsEjEKC3JwY19yZXF1'
    'ZXN0GAogASgLMg4ucGIuUnBjUmVxdWVzdEgAUgpycGNSZXF1ZXN0EkAKEHJldmVyc2VfcmVzcG'
    '9uc2UYCyABKAsyEy5wYi5SZXZlcnNlUmVzcG9uc2VIAFIPcmV2ZXJzZVJlc3BvbnNlQgoKCHJl'
    'cXVlc3Rz');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {
      '1': 'error',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.pb.Error',
      '9': 0,
      '10': 'error'
    },
    {
      '1': 'done',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.pb.Done',
      '9': 0,
      '10': 'done'
    },
    {
      '1': 'push',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.pb.Push',
      '9': 0,
      '10': 'push'
    },
    {
      '1': 'rpc_response',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.pb.RpcResponse',
      '9': 0,
      '10': 'rpcResponse'
    },
  ],
  '8': [
    {'1': 'responses'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRIhCgVlcnJvchgBIAEoCzIJLnBiLkVycm9ySABSBWVycm9yEh4KBGRvbmUYBi'
    'ABKAsyCC5wYi5Eb25lSABSBGRvbmUSHgoEcHVzaBgHIAEoCzIILnBiLlB1c2hIAFIEcHVzaBI0'
    'CgxycGNfcmVzcG9uc2UYCiABKAsyDy5wYi5ScGNSZXNwb25zZUgAUgtycGNSZXNwb25zZUILCg'
    'lyZXNwb25zZXM=');

@$core.Deprecated('Use rpcRequestDescriptor instead')
const RpcRequest$json = {
  '1': 'RpcRequest',
  '2': [
    {'1': 'path', '3': 1, '4': 1, '5': 9, '10': 'path'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `RpcRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpcRequestDescriptor = $convert.base64Decode(
    'CgpScGNSZXF1ZXN0EhIKBHBhdGgYASABKAlSBHBhdGgSGAoHcGF5bG9hZBgCIAEoDFIHcGF5bG'
    '9hZA==');

@$core.Deprecated('Use rpcResponseDescriptor instead')
const RpcResponse$json = {
  '1': 'RpcResponse',
  '2': [
    {'1': 'payload', '3': 1, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `RpcResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rpcResponseDescriptor = $convert
    .base64Decode('CgtScGNSZXNwb25zZRIYCgdwYXlsb2FkGAEgASgMUgdwYXlsb2Fk');

@$core.Deprecated('Use pushDescriptor instead')
const Push$json = {
  '1': 'Push',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'payload', '3': 2, '4': 1, '5': 12, '10': 'payload'},
    {'1': 'reverse_port', '3': 3, '4': 1, '5': 3, '10': 'reversePort'},
  ],
};

/// Descriptor for `Push`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pushDescriptor = $convert.base64Decode(
    'CgRQdXNoEhIKBHR5cGUYASABKAlSBHR5cGUSGAoHcGF5bG9hZBgCIAEoDFIHcGF5bG9hZBIhCg'
    'xyZXZlcnNlX3BvcnQYAyABKANSC3JldmVyc2VQb3J0');
