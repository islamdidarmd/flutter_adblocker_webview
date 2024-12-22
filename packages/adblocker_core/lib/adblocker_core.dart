import 'package:adblocker_core/css_rules_parser.dart';
import 'package:flutter/services.dart';

// Regular expressions for different filter types
final blockRulePattern =
    RegExp(r'\|\|([^$]+)\^?\$?(.*)'); // Block rules with options
final commentPattern = RegExp(r'^\s*!.*'); // Comments
final optionsPattern = RegExp(r'\$(.+)$'); // Filter options

class EasylistParser {
  final List<BlockRule> _urlsToBlock = [];
  final List<BlockRule> _exceptionUrls = [];
  final List<CSSRule> _cssRules = [];
  final List<CSSRule> _cssExceptionRules = [];

  final CSSRulesParser _cssRulesParser = CSSRulesParser();

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
      final isCSSRule = _parseCSSRule(line);
      if (isCSSRule) continue;

      // Handle exception rules
      final isException = line.startsWith('@@');
      if (isException) {
        line = line.substring(2); // Remove '@@'
      }

      // Handle blocking rules
      if (line.startsWith('||')) {
        _parseBlockingRule(line, isException);
        continue;
      }

      // Handle domain anchor rules
      if (line.startsWith('|')) {
        _parseDomainAnchorRule(line, isException);
        continue;
      }
    }
  }

  bool _parseCSSRule(String line) {
    final rule = _cssRulesParser.parseLine(line);
    if (rule == null) return false;

    if (rule.isException) {
      _cssExceptionRules.add(rule);
    } else {
      _cssRules.add(rule);
    }
    return true;
  }

  void _parseBlockingRule(String line, bool isException) {
    final match = blockRulePattern.firstMatch(line);
    if (match == null) return;

    var filter = match.group(1) ?? '';
    final optionsStr = match.group(2) ?? '';

    // Remove trailing separator
    if (filter.endsWith('^')) {
      filter = filter.substring(0, filter.length - 1);
    }

    final rule = BlockRule(
      filter: filter,
      isException: isException,
      isThirdParty: optionsStr.contains('third-party'),
      resourceType: _parseResourceType(optionsStr),
      domains: _parseDomains(optionsStr),
    );

    if (isException) {
      _exceptionUrls.add(rule);
    } else {
      _urlsToBlock.add(rule);
    }
  }

  ResourceType _parseResourceType(String options) {
    if (options.contains('script')) return ResourceType.script;
    if (options.contains('image')) return ResourceType.image;
    if (options.contains('stylesheet')) return ResourceType.stylesheet;
    if (options.contains('xmlhttprequest')) return ResourceType.xhr;
    if (options.contains('subdocument')) return ResourceType.subdocument;
    if (options.contains('websocket')) return ResourceType.websocket;
    return ResourceType.any;
  }

  DomainOptions? _parseDomains(String options) {
    final domainMatch = RegExp(r'domain=([^,]+)').firstMatch(options);
    if (domainMatch == null) return null;

    final domains = domainMatch.group(1)!.split('|');
    final includeDomains = <String>[];
    final excludeDomains = <String>[];

    for (final domain in domains) {
      if (domain.startsWith('~')) {
        excludeDomains.add(domain.substring(1));
      } else {
        includeDomains.add(domain);
      }
    }

    return DomainOptions(
      includeDomains: includeDomains,
      excludeDomains: excludeDomains,
    );
  }

  void _parseDomainAnchorRule(String line, bool isException) {
    var filter = line.substring(1);
    final rule = BlockRule(
      filter: filter,
      isException: isException,
    );

    if (isException) {
      _exceptionUrls.add(rule);
    } else {
      _urlsToBlock.add(rule);
    }
  }

  bool _domainMatches(String ruleDomain, String targetDomain) {
    return targetDomain == ruleDomain || targetDomain.contains(ruleDomain);
  }

  List<String> getAllCSSRules() {
    return _cssRules.map((rule) => rule.selector).toList();
  }

  List<String> getCSSRulesForWebsite(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return [];
    final domain = uri.host;

    final applicableRules = _cssRules
        .where((rule) => !rule.isException)
        .where(
          (rule) =>
              rule.domain.isEmpty ||
              rule.domain.any((d) => _domainMatches(d, domain)),
        )
        .map((rule) => rule.selector)
        .toList();

    return applicableRules;
  }

  List<BlockRule> getBlockRules() {
    return _urlsToBlock
        .where((rule) => !_exceptionUrls
            .any((exRule) => rule.filter.contains(exRule.filter)))
        .toList();
  }
}

class BlockRule {
  final String filter;
  final bool isException;
  final bool isThirdParty;
  final ResourceType resourceType;
  final DomainOptions? domains;

  BlockRule({
    required this.filter,
    this.isException = false,
    this.isThirdParty = false,
    this.resourceType = ResourceType.any,
    this.domains,
  });

  bool matchesDomain(String domain) {
    if (domains == null) return true;

    if (domains!.excludeDomains.any((d) => domain.endsWith(d))) {
      return false;
    }

    if (domains!.includeDomains.isEmpty) return true;
    return domains!.includeDomains.any((d) => domain.endsWith(d));
  }
}

class DomainOptions {
  final List<String> includeDomains;
  final List<String> excludeDomains;

  DomainOptions({
    this.includeDomains = const [],
    this.excludeDomains = const [],
  });
}

enum ResourceType {
  any,
  script,
  image,
  stylesheet,
  xhr,
  subdocument,
  websocket,
}
