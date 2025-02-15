import 'package:adblocker_core/src/core_impl.dart';
import 'package:adblocker_core/src/rules/resource_rule.dart';

abstract interface class AdblockerCore {
  Future<void> init();
  List<String> getCSSRulesForWebsite(String url);
  List<ResourceRule> getAllResourceRules();
  bool shouldBlockResource(String url);
  Future<void> dispose();

  static AdblockerCore get defaultInstance => AdlockerCoreImpl();
}
