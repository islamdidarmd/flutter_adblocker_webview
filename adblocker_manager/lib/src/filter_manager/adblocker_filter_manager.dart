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

  @override
  Future<void> init(AdBlockerFilterConfig config) async {
    await _createFilters(config.types);
  }

  @override
  Future<void> dispose() async {
    for (final filter in _filters) {
      unawaited(filter.dispose());
    }
  }

  Future<void> _createFilters(List<FilterType> types) async {
    for (final type in types) {
      final filter = await _filterfromType(type);
      _filters.add(filter);
    }
  }

  Future<AdBlockerFilter> _filterfromType(FilterType type,) async {
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
