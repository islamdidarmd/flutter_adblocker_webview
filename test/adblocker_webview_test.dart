import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdBlockerWebview', () {
    late AdBlockerWebviewController controller;

    setUp(() {
      controller = AdBlockerWebviewController.instance;
    });

    testWidgets('throws assertion error when both url and htmlData provided', (
      tester,
    ) async {
      expect(
        () => AdBlockerWebview(
          url: Uri.parse('https://example.com'),
          initialHtmlData: '<html><body>Test</body></html>',
          shouldBlockAds: true,
          adBlockerWebviewController: controller,
        ),
        throwsAssertionError,
      );
    });

    testWidgets(
      'throws assertion error when neither url nor htmlData provided',
      (tester) async {
        expect(
          () => AdBlockerWebview(
            shouldBlockAds: true,
            adBlockerWebviewController: controller,
          ),
          throwsAssertionError,
        );
      },
    );
  });
}
