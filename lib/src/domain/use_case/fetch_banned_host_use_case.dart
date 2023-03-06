import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';

import '../entity/host.dart';

class FetchBannedHostUseCase {
  final AdBlockerRepository adBlockerRepository;

  const FetchBannedHostUseCase({
    required this.adBlockerRepository,
  });

  Future<List<Host>> execute() async {
    return await adBlockerRepository.fetchBannedHostList();
  }
}
