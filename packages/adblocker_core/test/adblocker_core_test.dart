import 'package:adblocker_core/adblocker_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(TestWidgetsFlutterBinding.ensureInitialized);

  test('Verify css rules are parsed correctly', () async {
    final adblocker = EasylistParser();
    await adblocker.init();
    final rules = adblocker.getCSSRulesForWebsite('https://w3newspapers.com');
    final str = rules.join(', ');
    expect(rules.length, greaterThan(0));
  });
}
