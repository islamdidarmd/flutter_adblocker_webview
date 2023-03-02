import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:injectable/injectable.dart';

import '../entity/host.dart';

@injectable
class FetchBannedHostUseCase {
  final AdBlockerRepository adBlockerRepository;

  const FetchBannedHostUseCase({
    required this.adBlockerRepository,
  });

  Future<List<Host>> execute() async {

    return [];
  }
}
