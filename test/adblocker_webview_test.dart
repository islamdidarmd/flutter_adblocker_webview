import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_adblocker_repository_impl.dart';

void main() {
  test('Test controller initializes successfully', () async {
    final AdBlockerWebviewController instance = AdBlockerWebviewControllerImpl(
      repository: FakeAdBlockerRepositoryImpl(),
    );
    await instance.initialize();
  });
}
