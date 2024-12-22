final cssRulePattern = RegExp(r'^([^#]*)(##|#@#|#\?#)(.+)$');

class CSSRule {
  CSSRule({
    required this.domain,
    required this.selector,
    this.isException = false,
  });
  final List<String> domain;
  final String selector;
  final bool isException;
}

class CSSRulesParser {
  CSSRule? parseLine(String line) {
    final match = cssRulePattern.firstMatch(line);
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
