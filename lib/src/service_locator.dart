import 'package:get_it/get_it.dart';

import 'data/repository/adblocker_repository_impl.dart';
import 'domain/repository/adblocker_repository.dart';
import 'domain/use_case/fetch_banned_host_use_case.dart';

/// Service locator for this package.
/// Below is and example for getting an instance of a object registered wit [GetIt]:
/// ```dart
/// final useCase = ServiceLocator.get<FetchBannedHostUseCase>();
/// ```
/// Instances are registered automatically by annoting the class with @injectable
/// and running the build runner.

///ignore_for_file: prefer-static-class
///ignore_for_file: avoid-late-keyword
class ServiceLocator {
  static late final GetIt _getIt;

  static GetIt get getIt => _getIt;

  static void configureDependencies() {
    _getIt = GetIt.asNewInstance();
    _getIt
      ..registerFactory<AdBlockerRepository>(() => AdBlockerRepositoryImpl())
      ..registerFactory<FetchBannedHostUseCase>(
        () => FetchBannedHostUseCase(adBlockerRepository: get()),
      );
  }

  static T get<T extends Object>() => _getIt.get<T>();
}
