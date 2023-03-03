import 'domain/use_case/fetch_banned_host_use_case.dart';
import 'package:adblocker_webview/src/service_locator.dart';

import 'domain/entity/host.dart';

class AdBlockerWebviewController {
  static AdBlockerWebviewController? _instance;
  final _fetchBannedHostUseCase = ServiceLocator.get<FetchBannedHostUseCase>();
  final _bannedHost = <Host>[];

  static AdBlockerWebviewController get instance {
    if (_instance == null) {
      _instance = AdBlockerWebviewController._internal();
    }

    return _instance!; ///ignore: avoid-non-null-assertion
  }

  AdBlockerWebviewController._internal();

  Future<void> initialize() async {
    final hosts = await _fetchBannedHostUseCase.execute();
    _bannedHost
      ..clear()
      ..addAll(hosts);
  }

  bool isAd({required Host host}) {
    return _bannedHost.any(
      (element) {
        return element.domain == host.domain;
      },
    );
  }
}
