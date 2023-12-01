import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';

///ignore_for_file: avoid-top-level-members-in-tests
class FakeAdBlockerRepositoryImpl implements AdBlockerRepository {
  @override
  Future<List<Host>> fetchBannedHostList() async {
    return [
      const Host(authority: 'xyz.com'),
      const Host(authority: 'abc.com'),
    ];
  }
}
