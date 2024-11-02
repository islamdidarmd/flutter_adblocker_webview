import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adblocker_core_method_channel.dart';

abstract class AdblockerCorePlatform extends PlatformInterface {
  final String id;

  AdblockerCorePlatform({required this.id}) : super(token: _token);

  static final Object _token = Object();

  static AdblockerCorePlatform _instance = MethodChannelAdblockerCore(id: '');

  static AdblockerCorePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdblockerCorePlatform] when
  /// they register themselves.
  static set instance(AdblockerCorePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
