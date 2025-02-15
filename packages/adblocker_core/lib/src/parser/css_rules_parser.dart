import 'package:adblocker_core/src/rules/css_rule.dart';

final _cssRulePattern = RegExp(r'^([^#]*)(##|#@#|#\?#)(.+)$');

class CSSRulesParser {
  CSSRule? parseLine(String line) {
    final match = _cssRulePattern.firstMatch(line);
    if (match == null) return null;

    final domainGroup = match.group(1);
    final domain = <String>[];
    if (domainGroup != null && domainGroup.isNotEmpty) {
      domain.addAll(domainGroup.split(','));
    }

    final separator = match.group(2) ?? '##';
    final selector = match.group(3) ?? '';
    final isException = separator == '#@#';

    if (selector.contains('[') && selector.contains(']')) return null;

    return CSSRule(
      domain: domain,
      selector: selector,
      isException: isException,
    );
  }
}
