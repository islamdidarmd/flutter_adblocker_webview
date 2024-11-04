import 'package:adblocker_manager/src/config/adblocker_filter_config.dart';

abstract interface class FilterManager {
  Future<void> init(AdBlockerFilterConfig config);
  Future<void> dispose();
}
