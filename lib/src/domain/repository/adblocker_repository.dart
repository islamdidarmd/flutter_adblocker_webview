import 'package:adblocker_webview/src/domain/entity/host.dart';

abstract class AdBlockerRepository {
  Future<List<Host>> fetchBannedHostList();
}
