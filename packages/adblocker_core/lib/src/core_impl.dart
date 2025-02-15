import 'package:adblocker_core/src/core.dart';
import 'package:adblocker_core/src/parser/css_rules_parser.dart';
import 'package:adblocker_core/src/parser/resource_rules_parser.dart';
import 'package:adblocker_core/src/rules/css_rule.dart';
import 'package:adblocker_core/src/rules/resource_rule.dart';
import 'package:flutter/services.dart';

final _commentPattern = RegExp(r'^\s*!.*');

class AdlockerCoreImpl implements AdblockerCore {
  final List<CSSRule> _cssRules = [];
  final List<ResourceRule> _resourceRules = [];
  final List<ResourceRule> _resourceExceptionRules = [];
  final _cssRulesParser = CSSRulesParser();
  final _resourceRulesParser = ResourceRulesParser();

  @override
  Future<void> init() async {
    final str = await rootBundle
        .loadString('packages/adblocker_core/assets/easylist.txt');
    _parseRules(str);
  }

  @override
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

    return applicableRules
      ..add('.ads')
      ..add('#anchor-container');
  }

  @override
  List<ResourceRule> getAllResourceRules() {
    return [..._resourceRules, ..._resourceExceptionRules];
  }

  @override
  bool shouldBlockResource(String url) {
    final isException =
        _resourceExceptionRules.any((rule) => _domainMatches(rule.url, url));
    if (isException) return false;
    return _resourceRules.any((rule) => _domainMatches(rule.url, url));
  }

  @override
  Future<void> dispose() async {
    _cssRules.clear();
    _resourceRules.clear();
    _resourceExceptionRules.clear();
  }

  void _parseRules(String content) {
    final lines = content.split('\n');

    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty || line.startsWith(_commentPattern)) continue;

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
}
