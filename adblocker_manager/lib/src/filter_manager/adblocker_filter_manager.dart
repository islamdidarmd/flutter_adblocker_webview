import 'dart:async';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_manager/gen/assets.gen.dart';
import 'package:adblocker_manager/src/config/adblocker_filter_config.dart';
import 'package:adblocker_manager/src/config/filter_type.dart';
import 'package:adblocker_manager/src/filter_manager/filter_manager.dart';
import 'package:flutter/services.dart';

class AdBlockerFilterManager implements FilterManager {
  AdBlockerFilterManager();

  final List<AdBlockerFilter> _filters = [];
  final hidingCss =
      '{display: none !important; visibility: hidden !important;}';

  @override
  Future<void> init(AdBlockerFilterConfig config) async {
    await _createFilters(config.types);
  }

  @override
  Future<void> isAd(String url, String host) async {
    for (final filter in _filters) {
      await filter.isAd(url, host, FilterOption.unknown);
    }
  }

  @override
  Future<String> getStyleSheet(String host) async {
    final buffer = StringBuffer();
    final selectors = await _getElementHidingSelector(host);
    final rules = await _getCssRules(host);

    if (selectors.isNotEmpty) {
      buffer
        ..write(selectors)
        ..write(hidingCss);
    }
    if (rules.isNotEmpty) {
      buffer.writeAll(rules);
    }
    final seperated = _replaceEveryNth(buffer.toString(), ', ', hidingCss, 200);
    return seperated;
  }

  @override
  Future<String> getExtendedCssStyleSheet(String host) async {
    final buffer = StringBuffer();
    final selectors = await _getExtendedCssSelectors(host);
    if (selectors.isNotEmpty) {
      buffer
        ..write(selectors.join(','))
        ..write(hidingCss);
    }
    return buffer.toString();
  }

  @override
  Future<List<String>> getScriptlets(String host) async {
    final combinedScriptles = <String>[];
    for (final filter in _filters) {
      combinedScriptles.addAll(await filter.getScriptlets(host));
    }
    return combinedScriptles;
  }

  @override
  Future<void> dispose() async {
    for (final filter in _filters) {
      unawaited(filter.dispose());
    }
  }

  Future<String> _getElementHidingSelector(String host) async {
    final buffer = StringBuffer();
    for (final filter in _filters) {
      buffer
        ..write(await filter.getElementHidingSelector(host))
        ..write(', ');
    }
    return buffer.toString();
  }

  Future<List<String>> _getExtendedCssSelectors(String host) async {
    final combinedSelectors = <String>[];
    for (final filter in _filters) {
      combinedSelectors.addAll(await filter.getExtendedCssSelectors(host));
    }
    return combinedSelectors;
  }

  Future<List<String>> _getCssRules(String host) async {
    final combinedRules = <String>[];
    for (final filter in _filters) {
      combinedRules.addAll(await filter.getCssRules(host));
    }
    return combinedRules;
  }

  String _replaceEveryNth(
      String str, String oldValue, String newValue, int every,
      {bool ignoreCase = false}) {
    final regex = RegExp(oldValue, caseSensitive: !ignoreCase);
    var count = 0;
    return str.replaceAllMapped(regex, (match) {
      count++;
      if (count % every == 0) {
        return newValue;
      } else {
        return oldValue;
      }
    });
  }

  Future<void> _createFilters(List<FilterType> types) async {
    for (final type in types) {
      final filter = await _filterfromType(type);
      _filters.add(filter);
    }
  }

  Future<AdBlockerFilter> _filterfromType(FilterType type) async {
    late String rawData;
    const packagePrefix = 'packages/adblocker_manager/';

    switch (type) {
      case FilterType.adguardBase:
        rawData =
            await rootBundle.loadString('$packagePrefix${Assets.adguardBase}');
      case FilterType.adguardAnnyoance:
        rawData = await rootBundle
            .loadString('$packagePrefix${Assets.adguardAnnyoance}');
      case FilterType.easyPrivacyLite:
        rawData = await rootBundle
            .loadString('$packagePrefix${Assets.easyPrivacyLite}');
    }

    final filter = AdBlockerFilter();
    await filter.init();
    await filter.processRawData(rawData);
    return filter;
  }
}
