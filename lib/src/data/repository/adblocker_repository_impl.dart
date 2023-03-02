import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AdBlockerRepository)
class AdBlockerRepositoryImpl implements AdBlockerRepository {
  @override
  Future<List<Host>> fetchBannedHostList() {
    /// TODO: implement fetchBannedHostList
    throw UnimplementedError();
  }
}
