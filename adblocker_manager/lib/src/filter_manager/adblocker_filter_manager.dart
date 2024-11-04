import 'dart:async';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_manager/gen/assets.gen.dart';
import 'package:adblocker_manager/src/config/adblocker_filter_config.dart';
import 'package:adblocker_manager/src/config/filter_type.dart';
import 'package:adblocker_manager/src/filter_manager/filter_manager.dart';
import 'package:flutter/widgets.dart';

class AdBlockerFilterManager implements FilterManager {
  AdBlockerFilterManager(this.context);

  final BuildContext context;
  final List<AdBlockerFilter> _filters = [];

  @override
  Future<void> init(AdBlockerFilterConfig config) async {
    await _createFilters(context, config.types);
  }

  @override
  Future<void> dispose() async {
    for (final filter in _filters) {
      unawaited(filter.dispose());
    }
  }

  Future<void> _createFilters(
      BuildContext context, List<FilterType> types) async {
    for (final type in types) {
      final filter = await _filterfromType(context, type);
      _filters.add(filter);
    }
  }

  Future<AdBlockerFilter> _filterfromType(
    BuildContext context,
    FilterType type,
  ) async {
    late String rawData;
    switch (type) {
      case FilterType.adguardBase:
        rawData =
            await DefaultAssetBundle.of(context).loadString(Assets.adguardBase);
      case FilterType.adguardAnnyoance:
        rawData = await DefaultAssetBundle.of(context)
            .loadString(Assets.adguardAnnyoance);
      case FilterType.easyPrivacyLite:
        rawData = await DefaultAssetBundle.of(context)
            .loadString(Assets.easyPrivacyLite);
    }

    final filter = AdBlockerFilter();
    await filter.init();
    await filter.processRawData(rawData);
    return filter;
  }
}
