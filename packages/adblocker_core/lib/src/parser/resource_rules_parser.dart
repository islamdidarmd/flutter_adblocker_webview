import 'package:adblocker_core/src/rules/resource_rule.dart';

final _resourceRulePattern = RegExp(r'\|\|([^$*^]+)(?:\^)?\$?(.*)');

class ResourceRulesParser {
  ResourceRule? parseLine(String line) {
    final match = _resourceRulePattern.firstMatch(line);
    if (match == null) return null;

    final url = match.group(1) ?? '';
    final isException = line.startsWith('@@');

    return ResourceRule(url: url, isException: isException);
  }
}
