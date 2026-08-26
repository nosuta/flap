import 'package:flutter_test/flutter_test.dart';
import 'package:native_internal/native_internal.dart';
import 'package:native_internal/native_internal_platform_interface.dart';
import 'package:native_internal/native_internal_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNativeInternalPlatform
    with MockPlatformInterfaceMixin
    implements NativeInternalPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final NativeInternalPlatform initialPlatform = NativeInternalPlatform.instance;

  test('$MethodChannelNativeInternal is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNativeInternal>());
  });

  test('getPlatformVersion', () async {
    NativeInternal nativeInternalPlugin = NativeInternal();
    MockNativeInternalPlatform fakePlatform = MockNativeInternalPlatform();
    NativeInternalPlatform.instance = fakePlatform;

    expect(await nativeInternalPlugin.getPlatformVersion(), '42');
  });
}
