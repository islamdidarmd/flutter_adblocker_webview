import 'dart:io';

import 'package:adblocker_core/src/adblocker_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late AdBlockerFilter filter;

  setUp(() {
    filter = AdBlockerFilter();
  });

  tearDown(() async {
    await filter.dispose();
  });

  group('AdBlockerFilter Integration Tests', () {
    testWidgets('throws UnsupportedError on unsupported platforms', (tester) async {
      final filter = AdBlockerFilter();
      if (!Platform.isAndroid && !Platform.isIOS) {
        await expectLater(filter.init(), throwsUnsupportedError);
      }
    });
    testWidgets('initializes successfully', (tester) async {
      await expectLater(filter.init(), completes);
    });

    testWidgets('processes raw data correctly', (tester) async {
      await filter.init();
      const testRule = '||example.com^third-party';

      await expectLater(filter.processRawData(testRule), completes);
      expect(await filter.getRulesCount(), equals(1));
    });

    testWidgets('returns correct rules count', (tester) async {
      await filter.init();
      const testRules = '''
                  ||example.com^third-party
                  ||ads.example.com^
                  ||tracker.com^third-party
                  ''';

      await filter.processRawData(testRules);
      expect(await filter.getRulesCount(), equals(3));
    });
  });
}
