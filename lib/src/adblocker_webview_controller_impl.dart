import 'dart:collection';

import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/data/repository/adblocker_repository_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

///Implementation for [AdBlockerWebviewController]
class AdBlockerWebviewControllerImpl implements AdBlockerWebviewController {
  AdBlockerWebviewControllerImpl({AdBlockerRepository? repository})
      : _repository = repository ?? AdBlockerRepositoryImpl();
  final AdBlockerRepository _repository;

  WebViewController? _webViewController;

  final _bannedHost = <Host>[];

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
  void setInternalController(WebViewController controller) {
    _webViewController = controller;
  }

  @override
  Future<bool> canGoBack() async {
    if (_webViewController == null) {
      return false;
    }

    return _webViewController!.canGoBack();
  }

  @override
  Future<bool> canGoForward() async {
    if (_webViewController == null) {
      return false;
    }

    return _webViewController!.canGoForward();
  }

  @override
  Future<void> clearCache() async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.clearCache();
  }

  @override
  Future<String?> getTitle() async {
    if (_webViewController == null) {
      return null;
    }

    return _webViewController!.getTitle();
  }

  @override
  Future<void> goBack() async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.goBack();
  }

  @override
  Future<void> goForward() async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.goForward();
  }

  @override
  Future<void> loadUrl(String url) async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.loadRequest(Uri.parse(url));
  }

  @override
  Future<void> loadData(
    String data, {
    String? baseUrl,
  }) async {
    if (_webViewController == null) {
      return;
    }
    return _webViewController!.loadHtmlString(
      data,
      baseUrl: baseUrl,
    );
  }

  @override
  Future<void> reload() async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.reload();
  }

  @override
  Future<void> runScript(String script) async {
    if (_webViewController == null) {
      return;
    }

    return _webViewController!.runJavaScript(script);
  }
}
