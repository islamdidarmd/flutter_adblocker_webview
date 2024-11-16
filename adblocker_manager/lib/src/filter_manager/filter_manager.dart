import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_manager/src/filter_manager/adblocker_filter_manager.dart';

abstract interface class FilterManager {
  static FilterManager create() => AdBlockerFilterManager();

  Future<void> init(AdBlockerFilterConfig config);
  Future<void> isAd(String url, String host);
  Future<String> getStyleSheet(String host);
  Future<String> getExtendedCssStyleSheet(String host);
  Future<List<String>> getScriptlets(String host);
  Future<void> dispose();
}
