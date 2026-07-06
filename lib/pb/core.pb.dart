// This is a generated file - do not edit.
//
// Generated from core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Error
class Error extends $pb.GeneratedMessage {
  factory Error({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  Error._();

  factory Error.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Error.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Error',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Error copyWith(void Function(Error) updates) =>
      super.copyWith((message) => updates(message as Error)) as Error;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Error create() => Error._();
  @$core.override
  Error createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Error getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Error>(create);
  static Error? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// Cancel
class Cancel extends $pb.GeneratedMessage {
  factory Cancel({
    $core.int? code,
    $core.String? message,
    $fixnum.Int64? port,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (port != null) result.port = port;
    return result;
  }

  Cancel._();

  factory Cancel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Cancel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Cancel',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aInt64(3, _omitFieldNames ? '' : 'port')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cancel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Cancel copyWith(void Function(Cancel) updates) =>
      super.copyWith((message) => updates(message as Cancel)) as Cancel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Cancel create() => Cancel._();
  @$core.override
  Cancel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Cancel getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Cancel>(create);
  static Cancel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get port => $_getI64(2);
  @$pb.TagNumber(3)
  set port($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPort() => $_has(2);
  @$pb.TagNumber(3)
  void clearPort() => $_clearField(3);
}

/// Done
class Done extends $pb.GeneratedMessage {
  factory Done({
    $core.int? code,
    $core.String? message,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    return result;
  }

  Done._();

  factory Done.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Done.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Done',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Done clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Done copyWith(void Function(Done) updates) =>
      super.copyWith((message) => updates(message as Done)) as Done;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Done create() => Done._();
  @$core.override
  Done createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Done getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Done>(create);
  static Done? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

/// Init
class Init extends $pb.GeneratedMessage {
  factory Init({
    $fixnum.Int64? pushPort,
    $core.String? tempDir,
    $core.String? supportDir,
    $core.String? documentsDir,
    $core.String? appEncryptionKey,
  }) {
    final result = create();
    if (pushPort != null) result.pushPort = pushPort;
    if (tempDir != null) result.tempDir = tempDir;
    if (supportDir != null) result.supportDir = supportDir;
    if (documentsDir != null) result.documentsDir = documentsDir;
    if (appEncryptionKey != null) result.appEncryptionKey = appEncryptionKey;
    return result;
  }

  Init._();

  factory Init.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Init.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Init',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'pushPort')
    ..aOS(2, _omitFieldNames ? '' : 'tempDir')
    ..aOS(3, _omitFieldNames ? '' : 'supportDir')
    ..aOS(4, _omitFieldNames ? '' : 'documentsDir')
    ..aOS(5, _omitFieldNames ? '' : 'appEncryptionKey')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Init clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Init copyWith(void Function(Init) updates) =>
      super.copyWith((message) => updates(message as Init)) as Init;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Init create() => Init._();
  @$core.override
  Init createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Init getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Init>(create);
  static Init? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get pushPort => $_getI64(0);
  @$pb.TagNumber(1)
  set pushPort($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPushPort() => $_has(0);
  @$pb.TagNumber(1)
  void clearPushPort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tempDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set tempDir($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTempDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearTempDir() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get supportDir => $_getSZ(2);
  @$pb.TagNumber(3)
  set supportDir($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSupportDir() => $_has(2);
  @$pb.TagNumber(3)
  void clearSupportDir() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get documentsDir => $_getSZ(3);
  @$pb.TagNumber(4)
  set documentsDir($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDocumentsDir() => $_has(3);
  @$pb.TagNumber(4)
  void clearDocumentsDir() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get appEncryptionKey => $_getSZ(4);
  @$pb.TagNumber(5)
  set appEncryptionKey($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAppEncryptionKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearAppEncryptionKey() => $_clearField(5);
}

/// ReverseResponse is sent by Dart to Go as a reply to a Go->Dart->Go ReverseService call.
class ReverseResponse extends $pb.GeneratedMessage {
  factory ReverseResponse({
    $fixnum.Int64? reversePort,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (reversePort != null) result.reversePort = reversePort;
    if (payload != null) result.payload = payload;
    return result;
  }

  ReverseResponse._();

  factory ReverseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReverseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReverseResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'reversePort')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReverseResponse copyWith(void Function(ReverseResponse) updates) =>
      super.copyWith((message) => updates(message as ReverseResponse))
          as ReverseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReverseResponse create() => ReverseResponse._();
  @$core.override
  ReverseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReverseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReverseResponse>(create);
  static ReverseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get reversePort => $_getI64(0);
  @$pb.TagNumber(1)
  set reversePort($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReversePort() => $_has(0);
  @$pb.TagNumber(1)
  void clearReversePort() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

enum Request_Requests { init, cancel, rpcRequest, reverseResponse, notSet }

/// Request
class Request extends $pb.GeneratedMessage {
  factory Request({
    Init? init,
    Cancel? cancel,
    $fixnum.Int64? port,
    RpcRequest? rpcRequest,
    ReverseResponse? reverseResponse,
  }) {
    final result = create();
    if (init != null) result.init = init;
    if (cancel != null) result.cancel = cancel;
    if (port != null) result.port = port;
    if (rpcRequest != null) result.rpcRequest = rpcRequest;
    if (reverseResponse != null) result.reverseResponse = reverseResponse;
    return result;
  }

  Request._();

  factory Request.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Request.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Request_Requests> _Request_RequestsByTag = {
    1: Request_Requests.init,
    4: Request_Requests.cancel,
    10: Request_Requests.rpcRequest,
    11: Request_Requests.reverseResponse,
    0: Request_Requests.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Request',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..oo(0, [1, 4, 10, 11])
    ..aOM<Init>(1, _omitFieldNames ? '' : 'init', subBuilder: Init.create)
    ..aOM<Cancel>(4, _omitFieldNames ? '' : 'cancel', subBuilder: Cancel.create)
    ..aInt64(5, _omitFieldNames ? '' : 'port')
    ..aOM<RpcRequest>(10, _omitFieldNames ? '' : 'rpcRequest',
        subBuilder: RpcRequest.create)
    ..aOM<ReverseResponse>(11, _omitFieldNames ? '' : 'reverseResponse',
        subBuilder: ReverseResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request copyWith(void Function(Request) updates) =>
      super.copyWith((message) => updates(message as Request)) as Request;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Request create() => Request._();
  @$core.override
  Request createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Request getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Request>(create);
  static Request? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(4)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  Request_Requests whichRequests() => _Request_RequestsByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(4)
  @$pb.TagNumber(10)
  @$pb.TagNumber(11)
  void clearRequests() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Init get init => $_getN(0);
  @$pb.TagNumber(1)
  set init(Init value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInit() => $_has(0);
  @$pb.TagNumber(1)
  void clearInit() => $_clearField(1);
  @$pb.TagNumber(1)
  Init ensureInit() => $_ensure(0);

  @$pb.TagNumber(4)
  Cancel get cancel => $_getN(1);
  @$pb.TagNumber(4)
  set cancel(Cancel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCancel() => $_has(1);
  @$pb.TagNumber(4)
  void clearCancel() => $_clearField(4);
  @$pb.TagNumber(4)
  Cancel ensureCancel() => $_ensure(1);

  @$pb.TagNumber(5)
  $fixnum.Int64 get port => $_getI64(2);
  @$pb.TagNumber(5)
  set port($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(5)
  $core.bool hasPort() => $_has(2);
  @$pb.TagNumber(5)
  void clearPort() => $_clearField(5);

  @$pb.TagNumber(10)
  RpcRequest get rpcRequest => $_getN(3);
  @$pb.TagNumber(10)
  set rpcRequest(RpcRequest value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasRpcRequest() => $_has(3);
  @$pb.TagNumber(10)
  void clearRpcRequest() => $_clearField(10);
  @$pb.TagNumber(10)
  RpcRequest ensureRpcRequest() => $_ensure(3);

  @$pb.TagNumber(11)
  ReverseResponse get reverseResponse => $_getN(4);
  @$pb.TagNumber(11)
  set reverseResponse(ReverseResponse value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasReverseResponse() => $_has(4);
  @$pb.TagNumber(11)
  void clearReverseResponse() => $_clearField(11);
  @$pb.TagNumber(11)
  ReverseResponse ensureReverseResponse() => $_ensure(4);
}

enum Response_Responses { error, done, push, rpcResponse, notSet }

/// Response
class Response extends $pb.GeneratedMessage {
  factory Response({
    Error? error,
    Done? done,
    Push? push,
    RpcResponse? rpcResponse,
  }) {
    final result = create();
    if (error != null) result.error = error;
    if (done != null) result.done = done;
    if (push != null) result.push = push;
    if (rpcResponse != null) result.rpcResponse = rpcResponse;
    return result;
  }

  Response._();

  factory Response.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Response.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Response_Responses>
      _Response_ResponsesByTag = {
    1: Response_Responses.error,
    6: Response_Responses.done,
    7: Response_Responses.push,
    10: Response_Responses.rpcResponse,
    0: Response_Responses.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Response',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..oo(0, [1, 6, 7, 10])
    ..aOM<Error>(1, _omitFieldNames ? '' : 'error', subBuilder: Error.create)
    ..aOM<Done>(6, _omitFieldNames ? '' : 'done', subBuilder: Done.create)
    ..aOM<Push>(7, _omitFieldNames ? '' : 'push', subBuilder: Push.create)
    ..aOM<RpcResponse>(10, _omitFieldNames ? '' : 'rpcResponse',
        subBuilder: RpcResponse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response copyWith(void Function(Response) updates) =>
      super.copyWith((message) => updates(message as Response)) as Response;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Response create() => Response._();
  @$core.override
  Response createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Response getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Response>(create);
  static Response? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(10)
  Response_Responses whichResponses() =>
      _Response_ResponsesByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  @$pb.TagNumber(10)
  void clearResponses() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Error get error => $_getN(0);
  @$pb.TagNumber(1)
  set error(Error value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasError() => $_has(0);
  @$pb.TagNumber(1)
  void clearError() => $_clearField(1);
  @$pb.TagNumber(1)
  Error ensureError() => $_ensure(0);

  @$pb.TagNumber(6)
  Done get done => $_getN(1);
  @$pb.TagNumber(6)
  set done(Done value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDone() => $_has(1);
  @$pb.TagNumber(6)
  void clearDone() => $_clearField(6);
  @$pb.TagNumber(6)
  Done ensureDone() => $_ensure(1);

  @$pb.TagNumber(7)
  Push get push => $_getN(2);
  @$pb.TagNumber(7)
  set push(Push value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPush() => $_has(2);
  @$pb.TagNumber(7)
  void clearPush() => $_clearField(7);
  @$pb.TagNumber(7)
  Push ensurePush() => $_ensure(2);

  @$pb.TagNumber(10)
  RpcResponse get rpcResponse => $_getN(3);
  @$pb.TagNumber(10)
  set rpcResponse(RpcResponse value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasRpcResponse() => $_has(3);
  @$pb.TagNumber(10)
  void clearRpcResponse() => $_clearField(10);
  @$pb.TagNumber(10)
  RpcResponse ensureRpcResponse() => $_ensure(3);
}

/// RpcRequest
class RpcRequest extends $pb.GeneratedMessage {
  factory RpcRequest({
    $core.String? path,
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (path != null) result.path = path;
    if (payload != null) result.payload = payload;
    return result;
  }

  RpcRequest._();

  factory RpcRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RpcRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RpcRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcRequest copyWith(void Function(RpcRequest) updates) =>
      super.copyWith((message) => updates(message as RpcRequest)) as RpcRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpcRequest create() => RpcRequest._();
  @$core.override
  RpcRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RpcRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RpcRequest>(create);
  static RpcRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);
}

/// RpcResponse
class RpcResponse extends $pb.GeneratedMessage {
  factory RpcResponse({
    $core.List<$core.int>? payload,
  }) {
    final result = create();
    if (payload != null) result.payload = payload;
    return result;
  }

  RpcResponse._();

  factory RpcResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RpcResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RpcResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RpcResponse copyWith(void Function(RpcResponse) updates) =>
      super.copyWith((message) => updates(message as RpcResponse))
          as RpcResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RpcResponse create() => RpcResponse._();
  @$core.override
  RpcResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RpcResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RpcResponse>(create);
  static RpcResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get payload => $_getN(0);
  @$pb.TagNumber(1)
  set payload($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPayload() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayload() => $_clearField(1);
}

/// Push
class Push extends $pb.GeneratedMessage {
  factory Push({
    $core.String? type,
    $core.List<$core.int>? payload,
    $fixnum.Int64? reversePort,
  }) {
    final result = create();
    if (type != null) result.type = type;
    if (payload != null) result.payload = payload;
    if (reversePort != null) result.reversePort = reversePort;
    return result;
  }

  Push._();

  factory Push.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Push.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Push',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'pb'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..aInt64(3, _omitFieldNames ? '' : 'reversePort')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Push clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Push copyWith(void Function(Push) updates) =>
      super.copyWith((message) => updates(message as Push)) as Push;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Push create() => Push._();
  @$core.override
  Push createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Push getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Push>(create);
  static Push? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get payload => $_getN(1);
  @$pb.TagNumber(2)
  set payload($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPayload() => $_has(1);
  @$pb.TagNumber(2)
  void clearPayload() => $_clearField(2);

  /// reverse_port is set when Go requests a response from Dart (Go->Dart->Go ReverseService).
  /// 0 means fire-and-forget.
  @$pb.TagNumber(3)
  $fixnum.Int64 get reversePort => $_getI64(2);
  @$pb.TagNumber(3)
  set reversePort($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReversePort() => $_has(2);
  @$pb.TagNumber(3)
  void clearReversePort() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
