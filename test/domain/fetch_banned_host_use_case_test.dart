import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:adblocker_webview/src/domain/use_case/fetch_banned_host_use_case.dart';
import 'package:adblocker_webview/src/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_adblocker_repository_impl.dart';

void main() {
  ServiceLocator.configureDependencies();
  final getIt = ServiceLocator.getIt;

  setUp(() async {
    await getIt.reset();
    getIt
      ..registerFactory<AdBlockerRepository>(
        () => FakeAdBlockerRepositoryImpl(),
      )
      ..registerFactory<FetchBannedHostUseCase>(
        () => FetchBannedHostUseCase(adBlockerRepository: getIt.get()),
      );
  });

  test('Test UseCase Returns at least one host', () async {
    final useCase = getIt.get<FetchBannedHostUseCase>();
    final hostList = await useCase.execute();
    assert(hostList.length > 0, true);
  });

  tearDown(() {
    getIt.reset();
  });
}
