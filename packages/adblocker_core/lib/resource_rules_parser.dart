final resourceRulePattern = RegExp(r'\|\|([^$*^]+)(?:\^)?\$?(.*)');

class ResourceRule {
  ResourceRule({
    required this.url,
    this.isException = false,
  });
  final String url;
  final bool isException;
}

class ResourceRulesParser {
  ResourceRule? parseLine(String line) {
    final match = resourceRulePattern.firstMatch(line);
    if (match == null) return null;

    final url = match.group(1) ?? '';
    final isException = line.startsWith('@@');

    return ResourceRule(url: url, isException: isException);
  }
}
