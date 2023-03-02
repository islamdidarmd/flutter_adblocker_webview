import 'package:flutter_test/flutter_test.dart';

import 'package:adblocker_webview/adblocker_webview.dart';

void main() {
  test('Test controller initializes successfully', () async{
    final controller = AdBlockerWebviewController();
    await controller.initialize();
  });
}
