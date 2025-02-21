import 'package:adblocker_core/src/parser/css_rules_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CSSRulesParser', () {
    late CSSRulesParser parser;

    setUp(() {
      parser = CSSRulesParser();
    });

    test('parses basic element hiding rules', () {
      const rule = '##.ad-banner';
      final result = parser.parseLine(rule);

      expect(result, isNotNull);
      expect(result?.selector, equals('.ad-banner'));
      expect(result?.domain, isEmpty);
    });

    test('parses domain-specific rules', () {
      const rule = 'example.com##.ad-banner';
      final result = parser.parseLine(rule);

      expect(result, isNotNull);
      expect(result?.selector, equals('.ad-banner'));
      expect(result?.domain, contains('example.com'));
      expect(result?.domain, isNot(contains('test.com')));
    });

    test('parses multiple domain rules', () {
      const rule = 'example.com,test.com##.ad-banner';
      final result = parser.parseLine(rule);

      expect(result, isNotNull);
      expect(result?.selector, equals('.ad-banner'));
      expect(result?.domain, contains('example.com'));
      expect(result?.domain, contains('test.com'));
    });

    test('ignores comment lines', () {
      const rule = '! This is a comment';
      final result = parser.parseLine(rule);

      expect(result, isNull);
    });

    test('ignores empty lines', () {
      const rule = '';
      final result = parser.parseLine(rule);

      expect(result, isNull);
    });
  });
}
