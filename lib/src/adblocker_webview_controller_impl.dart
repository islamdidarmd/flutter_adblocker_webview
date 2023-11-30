import 'dart:collection';

import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/data/repository/adblocker_repository_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';

///Implementation for [AdBlockerWebviewController]
class AdBlockerWebviewControllerImpl implements AdBlockerWebviewController {
  late final AdBlockerRepository _repository;

  final _bannedHost = <Host>[];

  @override
  UnmodifiableListView<Host> get bannedHost =>
      UnmodifiableListView(_bannedHost);

  @override
  Future<void> initialize() async {
    _repository = AdBlockerRepositoryImpl();
    final hosts = await _repository.fetchBannedHostList();
    _bannedHost
      ..clear()
      ..addAll(hosts);
  }
}
