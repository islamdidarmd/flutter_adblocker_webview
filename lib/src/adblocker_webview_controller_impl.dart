import 'dart:collection';

import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/data/repository/adblocker_repository_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:flutter_inappwebview/src/in_app_webview/in_app_webview_controller.dart';

///Implementation for [AdBlockerWebviewController]
class AdBlockerWebviewControllerImpl implements AdBlockerWebviewController {
  final AdBlockerRepository _repository;

  InAppWebViewController? _inAppWebViewController;

  final _bannedHost = <Host>[];

  AdBlockerWebviewControllerImpl({AdBlockerRepository? repository})
      : _repository = repository ?? AdBlockerRepositoryImpl();

  @override
  UnmodifiableListView<Host> get bannedHost =>
      UnmodifiableListView(_bannedHost);

  @override
  Future<void> initialize() async {
    final hosts = await _repository.fetchBannedHostList();
    _bannedHost
      ..clear()
      ..addAll(hosts);
  }

  @override
  void setInternalController(InAppWebViewController controller) {
    this._inAppWebViewController = controller;
  }

  @override
  Future<bool> canGoBack() async {
    if (_inAppWebViewController == null) {
      return false;
    }

    return _inAppWebViewController!.canGoBack();
  }

  @override
  Future<void> goBack() async {
    if (_inAppWebViewController == null) {
      return;
    }

    return _inAppWebViewController!.goBack();
  }

  @override
  Future<bool> canGoForward() async {
    if (_inAppWebViewController == null) {
      return false;
    }

    return _inAppWebViewController!.canGoForward();
  }

  @override
  Future<void> goForward() async {
    if (_inAppWebViewController == null) {
      return;
    }

    return _inAppWebViewController!.goForward();
  }

  @override
  Future<void> reload() async {
    if (_inAppWebViewController == null) {
      return;
    }

    return _inAppWebViewController!.reload();
  }
}
