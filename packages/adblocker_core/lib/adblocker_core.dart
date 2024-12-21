import 'package:flutter/services.dart';

// Regular expressions for different filter types
final blockRulePattern =
    RegExp(r'\|\|([^$]+)\^?\$?(.*)'); // Block rules with options
final cssRulePattern =
    RegExp(r'^([^#]*)(##|#@#|#\?#)(.+)$'); // CSS hiding rules
final commentPattern = RegExp(r'^\s*!.*'); // Comments
final optionsPattern = RegExp(r'\$(.+)$'); // Filter options

class EasylistParser {
  final List<BlockRule> _urlsToBlock = [];
  final List<BlockRule> _exceptionUrls = [];
  final List<CSSRule> cssRules = [];
  final List<CSSRule> cssExceptionRules = [];

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

      // Handle exception rules
      final isException = line.startsWith('@@');
      if (isException) {
        line = line.substring(2); // Remove '@@'
      }

      // Handle element hiding rules
      if (line.contains('##') || line.contains('#@#') || line.contains('#?#')) {
        _parseCSSRule(line, isException);
        continue;
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

  void _parseCSSRule(String line, bool isException) {
    final match = cssRulePattern.firstMatch(line);
    if (match == null) return;

    final domain = match.group(1) ?? '';
    final separator = match.group(2) ?? '##';
    final selectors = match.group(3)?.split(',') ?? [];

    final rule = CSSRule(
      domain: domain,
      selectors: selectors,
      isExtendedSelector: separator == '#?#',
    );

    if (isException || separator == '#@#') {
      cssExceptionRules.add(rule);
    } else {
      cssRules.add(rule);
    }
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
    if (ruleDomain.isEmpty) return true;
    return targetDomain == ruleDomain || targetDomain.endsWith('.$ruleDomain');
  }

  List<String> getCSSRulesForWebsite(String domain) {
    final applicableRules = cssRules
        .where((rule) => _domainMatches(rule.domain, domain))
        .expand((rule) => rule.selectors)
        .toList();

    final exceptions = cssExceptionRules
        .where((rule) => _domainMatches(rule.domain, domain))
        .expand((rule) => rule.selectors)
        .toSet();

    return applicableRules
        .where((selector) => !exceptions.contains(selector))
        .toList();
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

class CSSRule {
  final String domain;
  final List<String> selectors;
  final bool isExtendedSelector;

  CSSRule({
    required this.domain,
    required this.selectors,
    this.isExtendedSelector = false,
  });
}
