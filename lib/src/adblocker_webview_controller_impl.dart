import 'dart:collection';

import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

///Implementation for [AdBlockerWebviewController]
class AdBlockerWebviewControllerImpl implements AdBlockerWebviewController {
  AdBlockerWebviewControllerImpl();

  WebViewController? _webViewController;
  final AdblockFilterManager _adBlockManager = AdblockFilterManager();
  final _bannedResourceRules = <ResourceRule>[];

  @override
  Future<void> initialize(
    FilterConfig filterConfig,
    List<ResourceRule> additionalResourceRules,
  ) async {
    await _adBlockManager.init(filterConfig);
    _bannedResourceRules
      ..clear()
      ..addAll(_adBlockManager.getAllResourceRules())
      ..addAll(additionalResourceRules);
  }

  @override
  UnmodifiableListView<ResourceRule> get bannedResourceRules =>
      UnmodifiableListView(_bannedResourceRules);

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
  List<String> getCssRulesForWebsite(String url) =>
      _adBlockManager.getCSSRulesForWebsite(url);

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
  Future<void> loadData(String data, {String? baseUrl}) async {
    if (_webViewController == null) {
      return;
    }
    return _webViewController!.loadHtmlString(data, baseUrl: baseUrl);
  }

  @override
  bool shouldBlockResource(String url) =>
      _adBlockManager.shouldBlockResource(url);

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
