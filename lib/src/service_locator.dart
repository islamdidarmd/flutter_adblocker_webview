import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'service_locator.config.dart';

/// Service locator for this package.
/// Below is and example for getting an instance of a object registered wit [GetIt]:
/// ```dart
/// final useCase = ServiceLocator.get<FetchBannedHostUseCase>();
/// ```
/// Instances are registered automatically by annoting the class with @injectable
/// and running the build runner.

///ignore_for_file: prefer-static-class
class ServiceLocator {
  static final GetIt instance = GetIt.asNewInstance();

  static T get<T extends Object>() => instance.get<T>();
}

@InjectableInit(initializerName: 'initGetIt', preferRelativeImports: true)
GetIt configureDependencies() => ServiceLocator.instance.initGetIt();
