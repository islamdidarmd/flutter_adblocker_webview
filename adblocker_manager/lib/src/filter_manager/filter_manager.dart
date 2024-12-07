import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_manager/src/filter_manager/adblocker_filter_manager.dart';

abstract interface class FilterManager {
  static FilterManager create() => AdBlockerFilterManager();

  Future<void> init(AdBlockerFilterConfig config);
  Future<List<String>> getBlockedUrls();
  Future<bool> isAd(String url);
  Future<String> getElementHidingSelectors();
  Future<void> dispose();
}
