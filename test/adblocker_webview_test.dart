import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adblocker_webview/adblocker_webview.dart';

import 'fakes/fake_adblocker_repository_impl.dart';

void main() {
  test('Test controller initializes successfully', () async {
    final instance = AdBlockerWebviewController.instance;
    await instance.initialize();
  });
}
