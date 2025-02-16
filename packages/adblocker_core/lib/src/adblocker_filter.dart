import 'package:adblocker_core/src/adblocker_filter_impl.dart';
import 'package:adblocker_core/src/rules/resource_rule.dart';

abstract interface class AdblockerFilter {
  Future<void> init(String filterData);
  List<String> getCSSRulesForWebsite(String url);
  List<ResourceRule> getAllResourceRules();
  bool shouldBlockResource(String url);
  Future<void> dispose();

  static AdblockerFilter createInstance() => AdblockerFilterImpl();
}
