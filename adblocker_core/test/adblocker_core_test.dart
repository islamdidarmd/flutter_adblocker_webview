import 'package:flutter_test/flutter_test.dart';
import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_core/adblocker_core_platform_interface.dart';
import 'package:adblocker_core/adblocker_core_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdblockerCorePlatform
    with MockPlatformInterfaceMixin
    implements AdblockerCorePlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdblockerCorePlatform initialPlatform = AdblockerCorePlatform.instance;

  test('$MethodChannelAdblockerCore is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdblockerCore>());
  });

  test('getPlatformVersion', () async {
    AdblockerCore adblockerCorePlugin = AdblockerCore();
    MockAdblockerCorePlatform fakePlatform = MockAdblockerCorePlatform();
    AdblockerCorePlatform.instance = fakePlatform;

    expect(await adblockerCorePlugin.getPlatformVersion(), '42');
  });
}
