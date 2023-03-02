import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';
import 'service_locator.config.dart';

///ignore_for_file: prefer-static-class
class ServiceLocator {
  static final GetIt instance = GetIt.asNewInstance();

  static T get<T extends Object>() => ServiceLocator.get<T>();
}

@InjectableInit(initializerName: 'initGetIt', preferRelativeImports: true)
GetIt configureDependencies() => ServiceLocator.instance.initGetIt();
