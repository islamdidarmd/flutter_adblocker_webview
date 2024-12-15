import 'package:flutter/services.dart';

final blockRulePattern = RegExp(r'\|\|([^$]+)\^?\$(\w+)?'); // Block rules
final cssRulePattern = RegExp(r'^([^#]+)##(.+)$'); // CSS hiding rules

class EasylistParser {
  final List<Rule> rules = [];
  final List<CSSRule> cssRules = [];

  Future<void> init() async {
    final str = await rootBundle
        .loadString('packages/adblocker_core/assets/easylist.txt');
    _parseRules(str);
  }

  void _parseRules(String content) {
    final lines = content.split('\n');

    for (var line in lines) {
      // Ignore comments and empty lines
      line = line.trim();
      if (line.isEmpty || line.startsWith('!')) continue;

      // Match CSS hiding rules
      if (line.contains('##')) {
        final parts = line.split('##');
        final domain = parts[0];
        final selectors = parts[1].split(',');
        cssRules.add(CSSRule(domain: domain, selectors: selectors));
        continue;
      }

      // Match filter rules
      if (line.startsWith('||')) {
        final parts = line.split(r'$');
        var filter = parts[0].substring(2); // Remove "||"

        // Remove trailing '^' if present
        if (filter.endsWith('^')) {
          filter = filter.substring(0, filter.length - 1);
        }

        final type = parts.length > 1 ? parts[1] : 'all';
        rules.add(Rule(type: type, filter: filter));
        continue;
      }

      // Match exception rules
      if (line.startsWith('@@')) {
        // Handle exceptions if needed
        continue;
      }
    }
  }

  List<String> getCSSRulesForWebsite(String domain) {
    // Filter CSS rules based on domain (if domain-specific rules are added)
    return cssRules
        .where((rule) => rule.domain == domain || rule.domain.isEmpty)
        .expand((rule) => rule.selectors)
        .toList();
  }

  List<Rule> getFilterRules() => rules;
}

class Rule {
  final String type; // script, image, stylesheet, etc.
  final String filter; // Domain, subdomain, path, etc.

  Rule({required this.type, required this.filter});
}

class CSSRule {
  final String domain;
  final List<String> selectors;

  CSSRule({required this.domain, required this.selectors});
}
