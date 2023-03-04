import 'domain/use_case/fetch_banned_host_use_case.dart';
import 'package:adblocker_webview/src/service_locator.dart';

import 'domain/entity/host.dart';
/// The controller for [AdBlockerWebviewWidget].
/// Below is and Example of getting a singleton instance:
/// ```dart
///    final _adBlockerWebviewController = AdBlockerWebviewController.instance;
/// ```
/// It's better to warm up the controller before displaying the webview. It's possible to do that by:
/// ```dart
///   @override
///   void initState() {
///     super.initState();
///     _adBlockerWebviewController.initialize();
///     /// ... Other code here.
///   }
/// ```
///
class AdBlockerWebviewController {
  static AdBlockerWebviewController? _instance;
  late final FetchBannedHostUseCase _fetchBannedHostUseCase; ///ignore: avoid-late-keyword
  final _bannedHost = <Host>[];

  static AdBlockerWebviewController get instance {
    if (_instance == null) {
      _instance = AdBlockerWebviewController._internal();
    }

    return _instance!; ///ignore: avoid-non-null-assertion
  }

  AdBlockerWebviewController._internal();

  Future<void> initialize() async {
    final getIt = configureDependencies(); ///ignore: unused_local_variable
    _fetchBannedHostUseCase = ServiceLocator.get<FetchBannedHostUseCase>();

    final hosts = await _fetchBannedHostUseCase.execute();
    _bannedHost
      ..clear()
      ..addAll(hosts);
  }

  bool isAd({required Host host}) {
    return _bannedHost.any(
      (element) {
        return host.domain.contains(element.domain);
      },
    );
  }
}
