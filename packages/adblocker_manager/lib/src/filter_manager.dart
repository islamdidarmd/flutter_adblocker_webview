import 'package:adblocker_core/adlocker_core.dart';
import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:flutter/services.dart';

/// Manager class that handles multiple ad-blocking filters
class AdblockFilterManager {
  final List<AdblockerFilter> _filters = [];
  bool _isInitialized = false;

  /// Initializes the filter manager with the given configuration
  ///
  /// Throws [FilterInitializationException] if initialization fails
  Future<void> init(FilterConfig config) async {
    try {
      _filters.clear();

      for (final filterType in config.filterTypes) {
        final filter = await _createFilter(filterType);
        _filters.add(filter);
      }

      _isInitialized = true;
    } catch (e) {
      throw FilterInitializationException('Failed to initialize filters', e);
    }
  }

  /// Creates a filter instance based on the filter type
  Future<AdblockerFilter> _createFilter(FilterType type) async {
    final filter = AdblockerFilter.createInstance();
    switch (type) {
      case FilterType.easyList:
        await filter.init(
          await rootBundle.loadString(
            'packages/adblocker_manager/assets/easylist.txt',
          ),
        );
        return filter;
      case FilterType.adGuard:
        await filter.init(
          await rootBundle.loadString(
            'packages/adblocker_manager/assets/adguard_base.txt',
          ),
        );
        return filter;
    }
  }

  /// Checks if a resource should be blocked
  ///
  /// Returns true if any filter indicates the resource should be blocked
  bool shouldBlockResource(String url) {
    _checkInitialization();

    // Return true if any filter says to block
    return _filters.any((filter) => filter.shouldBlockResource(url));
  }

  /// Gets CSS rules for the given website
  ///
  /// Returns a list of unique CSS rules from all filters
  List<String> getCSSRulesForWebsite(String domain) {
    _checkInitialization();

    // Combine unique rules from all filters
    final rules = <String>{};
    for (final filter in _filters) {
      rules.addAll(filter.getCSSRulesForWebsite(domain));
    }
    return rules.toList();
  }

  /// Gets all resource rules from all filters
  List<ResourceRule> getAllResourceRules() {
    _checkInitialization();

    return _filters.expand((filter) => filter.getAllResourceRules()).toList();
  }

  /// Checks if the manager is initialized
  void _checkInitialization() {
    if (!_isInitialized) {
      throw FilterException(
        'AdblockFilterManager is not initialized. Call init() first.',
      );
    }
  }
}
