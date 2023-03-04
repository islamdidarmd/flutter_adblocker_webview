import '../entity/host.dart';

abstract class AdBlockerRepository {
  Future<List<Host>> fetchBannedHostList();
}
