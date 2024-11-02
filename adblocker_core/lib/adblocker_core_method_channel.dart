import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adblocker_core_platform_interface.dart';

/// An implementation of [AdblockerCorePlatform] that uses method channels.
class MethodChannelAdblockerCore extends AdblockerCorePlatform {
  MethodChannelAdblockerCore({required super.id});

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adblocker_core');
}
