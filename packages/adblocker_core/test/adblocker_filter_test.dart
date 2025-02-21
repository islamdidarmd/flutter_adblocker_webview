import 'package:adblocker_core/src/adblocker_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdBlockerFilter', () {
    late AdblockerFilter filter;

    setUp(() async {
      filter = AdblockerFilter.createInstance();
      await filter.init('''
        ! Test filter list
        ||ads.example.com^
        ||tracker.com^
        @@||whitelist.example.com^
        example.com##.ad-banner
        test.com##.sponsored
        ~news.com##.advertisement
      ''');
    });

    group('Resource blocking', () {
      test('blocks matching URLs', () {
        expect(
          filter.shouldBlockResource('https://ads.example.com/banner.jpg'),
          isTrue,
        );
        expect(
          filter.shouldBlockResource('https://tracker.com/pixel.gif'),
          isTrue,
        );
      });

      test('allows non-matching URLs', () {
        expect(
          filter.shouldBlockResource('https://example.com/image.jpg'),
          isFalse,
        );
      });

      test('respects exception rules', () {
        expect(
          filter.shouldBlockResource('https://whitelist.example.com/ads.js'),
          isFalse,
        );
      });
    });

    group('CSS rules', () {
      test('returns rules for matching domain', () {
        final rules = filter.getCSSRulesForWebsite('https://example.com');
        expect(rules, contains('.ad-banner'));
      });

      test('returns rules for multiple domains', () {
        final rules = filter.getCSSRulesForWebsite('https://test.com');
        expect(rules, contains('.sponsored'));
      });

      test('respects domain exclusions', () {
        final rules = filter.getCSSRulesForWebsite('https://news.com');
        expect(rules, isNot(contains('.advertisement')));
      });

      test('returns empty list for non-matching domain', () {
        final rules = filter.getCSSRulesForWebsite('https://random.com');
        expect(rules, isEmpty);
      });
    });

    test('getAllResourceRules returns all resource rules', () {
      final rules = filter.getAllResourceRules();
      expect(rules, hasLength(3)); // 2 block rules + 1 exception rule
      expect(rules.where((rule) => !rule.isException), hasLength(2));
      expect(rules.where((rule) => rule.isException), hasLength(1));
    });
  });
}
