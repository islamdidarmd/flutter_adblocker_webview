import 'dart:async';
import 'dart:io';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_manager/gen/assets.gen.dart';
import 'package:adblocker_manager/src/config/adblocker_filter_config.dart';
import 'package:adblocker_manager/src/config/filter_type.dart';
import 'package:adblocker_manager/src/filter_manager/filter_manager.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  Future<bool> isAd(String url) async {
    for (final filter in _filters) {
      if (await filter.isAd(url)) {
        return true;
      }
    }

    return false;
  }

  @override
  Future<List<String>> getBlockedUrls() async {
    final combined = <String>[];
    for (final filter in _filters) {
      combined.addAll(await filter.getBlockedUrls());
    }
    return combined;
  }

  @override
  Future<String> getElementHidingSelectors() async {
    final buffer = StringBuffer();
    for (final filter in _filters) {
      buffer
        ..write(await filter.getElementHidingSelectors())
        ..write(', ');
    }
    return buffer.toString();
  }

  @override
  Future<void> dispose() async {
    for (final filter in _filters) {
      unawaited(filter.dispose());
    }
  }

  /* Future<String> _getElementHidingSelector(String host) async {
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
  }*/

  Future<void> _createFilters(List<FilterType> types) async {
    for (final type in types) {
      final filter = await _filterfromType(type);
      _filters.add(filter);
    }
  }

  Future<AdBlockerFilter> _filterfromType(FilterType type) async {
    late ByteData rawData;
    late String fileName;
    const packagePrefix = 'packages/adblocker_manager/';

    final dir = await getApplicationSupportDirectory();

    switch (type) {
      case FilterType.easyList:
        rawData = await rootBundle.load('$packagePrefix${Assets.easylist}');
        fileName = 'easylist.txt';
      case FilterType.adguardBase:
        rawData = await rootBundle.load('$packagePrefix${Assets.adguardBase}');
        fileName = 'adguardBase.txt';
      case FilterType.adguardAnnyoance:
        rawData =
            await rootBundle.load('$packagePrefix${Assets.adguardAnnyoance}');
        fileName = 'adguardAnnyoance.txt';
      case FilterType.easyPrivacyLite:
        rawData =
            await rootBundle.load('$packagePrefix${Assets.easyPrivacyLite}');
        fileName = 'easyPrivacyLite.txt';
    }

    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(rawData.buffer.asUint8List());

    final filter = AdBlockerFilter();
    await filter.init();
    await filter.processFile(filePath);
    return filter;
  }
}
