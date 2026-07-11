import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_internal_method_channel.dart';

abstract class NativeInternalPlatform extends PlatformInterface {
  /// Constructs a NativeInternalPlatform.
  NativeInternalPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeInternalPlatform _instance = MethodChannelNativeInternal();

  /// The default instance of [NativeInternalPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeInternal].
  static NativeInternalPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeInternalPlatform] when
  /// they register themselves.
  static set instance(NativeInternalPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
