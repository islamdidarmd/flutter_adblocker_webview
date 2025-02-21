import 'package:adblocker_core/src/parser/resource_rules_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResourceRulesParser', () {
    late ResourceRulesParser parser;

    setUp(() {
      parser = ResourceRulesParser();
    });

    test('parses domain anchor rules correctly', () {
      const rule = '||ads.example.com^';
      final result = parser.parseLine(rule);

      expect(result, isNotNull);
      expect(result?.url, equals('ads.example.com'));
      expect(result?.isException, isFalse);
    });

    test('parses exception rules correctly', () {
      const rule = '@@||ads.example.com^';
      final result = parser.parseLine(rule);

      expect(result, isNotNull);
      expect(result?.url, equals('ads.example.com'));
      expect(result?.isException, isTrue);
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

    test('ignores invalid rules', () {
      const rule = 'not a valid rule';
      final result = parser.parseLine(rule);

      expect(result, isNull);
    });
  });
}
