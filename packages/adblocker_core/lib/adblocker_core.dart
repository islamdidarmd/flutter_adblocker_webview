import 'package:adblocker_core/css_rules_parser.dart';
import 'package:adblocker_core/resource_rules_parser.dart';
import 'package:flutter/services.dart';

// Regular expressions for different filter types // Block rules with options
final commentPattern = RegExp(r'^\s*!.*'); // Comments
final optionsPattern = RegExp(r'\$(.+)$'); // Filter options

class EasylistParser {
  final List<CSSRule> _cssRules = [];
  final List<ResourceRule> _resourceRules = [];
  final List<ResourceRule> _resourceExceptionRules = [];
  final _cssRulesParser = CSSRulesParser();
  final _resourceRulesParser = ResourceRulesParser();

  Future<void> init() async {
    final str = await rootBundle
        .loadString('packages/adblocker_core/assets/easylist.txt');
    _parseRules(str);
  }

  void _parseRules(String content) {
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('!')) continue;

      // Handle element hiding rules
      final isCSSParsed = _parseCSSRule(line);
      if (isCSSParsed) continue;

      final isResourceParsed = _parseResourceRule(line);
      if (isResourceParsed) continue;
    }
  }

  bool _parseCSSRule(String line) {
    final rule = _cssRulesParser.parseLine(line);
    if (rule == null) return false;
    _cssRules.add(rule);
    return true;
  }

  bool _parseResourceRule(String line) {
    final rule = _resourceRulesParser.parseLine(line);
    if (rule == null) return false;
    if (rule.isException) {
      _resourceExceptionRules.add(rule);
    } else {
      _resourceRules.add(rule);
    }
    return true;
  }

  bool _domainMatches(String ruleDomain, String targetDomain) {
    return targetDomain == ruleDomain || targetDomain.contains(ruleDomain);
  }

  List<String> getCSSRulesForWebsite(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return [];
    final domain = uri.host;
    final applicableRules = <String>[];
    final applicableExceptionRules = <String, bool>{};

    for (final rule in _cssRules) {
      if (applicableExceptionRules.containsKey(rule.selector)) continue;

      if (rule.domain.isEmpty ||
          rule.domain.any((d) => _domainMatches(d, domain))) {
        if (rule.isException) {
          applicableExceptionRules[rule.selector] = true;
        } else {
          applicableRules.add(rule.selector);
        }
      }
    }

    applicableExceptionRules.keys.forEach(applicableRules.remove);

    return applicableRules..add('.ads')..add('#anchor-container');
  }

  List<ResourceRule> getAllResourceRules() {
    return [..._resourceRules, ..._resourceExceptionRules];
  }

  bool shouldBlockResource(String url) {
    final isException =
        _resourceExceptionRules.any((rule) => _domainMatches(rule.url, url));
    if (isException) return false;
    return _resourceRules.any((rule) => _domainMatches(rule.url, url));
  }
}
