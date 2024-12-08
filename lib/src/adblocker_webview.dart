import 'dart:async';
import 'dart:io';

import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/css.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/js.dart';
import 'package:adblocker_webview/src/logger.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A webview implementation of in Flutter that blocks most of the ads that
/// appear inside of the webpages.
class AdBlockerWebview extends StatefulWidget {
  const AdBlockerWebview({
    required this.adBlockerWebviewController,
    required this.shouldBlockAds,
    required this.url,
    this.initialHtmlData,
    this.onLoadStart,
    this.onLoadFinished,
    this.onProgress,
    this.onLoadError,
    this.onUrlChanged,
    this.additionalHostsToBlock = const [],
    super.key,
  }) : assert(
            (url == null && initialHtmlData != null) ||
                (url != null && initialHtmlData == null),
            'Both url and initialHtmlData can not be non null');

  /// Required: The initial [Uri] url that will be displayed in webview.
  final Uri url;

  final String? initialHtmlData;

  /// Required: The controller for [AdBlockerWebview].
  /// See more at [AdBlockerWebviewController].
  final AdBlockerWebviewController adBlockerWebviewController;

  /// Required: Specifies whether to block or allow ads.
  final bool shouldBlockAds;

  /// Invoked when a page has started loading.
  final void Function(String? url)? onLoadStart;

  /// Invoked when a page has finished loading.
  final void Function(String? url)? onLoadFinished;

  /// Invoked when a page is loading to report the progress.
  final void Function(int progress)? onProgress;

  /// Invoked when the page title is changed.
  final void Function(String? url)? onUrlChanged;

  final List<Host> additionalHostsToBlock;

  /// Invoked when a loading error occurred.
  final void Function(
    String? url,
    int code,
  )? onLoadError;

  @override
  State<AdBlockerWebview> createState() => _AdBlockerWebviewState();
}

class _AdBlockerWebviewState extends State<AdBlockerWebview> {
  final _webViewKey = GlobalKey();
  final _filterManager = FilterManager.create();
  late final WebViewController _webViewController;

  late Future<void> _depsFuture;

  @override
  void initState() {
    super.initState();
    _depsFuture = _init();
  }

  Future<void> _init() async {
    await _filterManager.init(AdBlockerFilterConfig(types: [
      FilterType.adguardBase,
      FilterType.adguardAnnyoance,
      FilterType.easyPrivacyLite,
    ]));
    _webViewController = WebViewController()
      ..setUserAgent(_getUserAgent())
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    _setNavigationDelegate();
    //_setJavaScriptHandlers();
    widget.adBlockerWebviewController.setInternalController(_webViewController);
    _webViewController.loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _depsFuture,
      builder: (_, state) {
        if (state.connectionState == ConnectionState.done) {
          return WebViewWidget(
            key: _webViewKey,
            controller: _webViewController,
          );
        }
        return const SizedBox();
      },
    );
  }

  void _setNavigationDelegate() {
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) async {
          _runJS(url);
          widget.onLoadStart?.call(url);
        },
        onPageFinished: (url) {
          widget.onLoadFinished?.call(url);
        },
        onProgress: (progress) => widget.onProgress?.call(progress),
        onHttpError: (error) => widget.onLoadError?.call(
          error.request?.uri.toString(),
          error.response?.statusCode ?? -1,
        ),
        onUrlChange: (change) => widget.onUrlChanged?.call(change.url),
      ),
    );
  }

  void _runJS(String host) async {
    final styleSheet = await _filterManager.getStyleSheet(host);
    final es = await _filterManager.getExtendedCssStyleSheet(host);
    final sc = await _filterManager.getScriptlets(host);
    _webViewController.runJavaScript(getElemeHide(styleSheet, es));
    _webViewController.runJavaScript(getScriptlet(sc));
    _webViewController.runJavaScript(resourceLoadingBlockerScript);
  }

  void _setJavaScriptHandlers() {
    _webViewController
      ..addJavaScriptChannel(
        'GetStyleSheet',
        onMessageReceived: (message) async {
          debugLog("Passed arguments: ${message.message}");
          final styleSheet =
              await _filterManager.getStyleSheet(message.message);
          debugLog("stylesheet: $styleSheet");
          _webViewController.runJavaScript(sendStyleSheetToJs(styleSheet));
        },
      )
      ..addJavaScriptChannel(
        'GetExtendedCssStyleSheet',
        onMessageReceived: (message) async {
          debugLog("Passed Extended arguments: ${message.message}");
          final styleSheet =
              await _filterManager.getExtendedCssStyleSheet(message.message);
          debugLog("Extended stylesheet: $styleSheet");
          _webViewController
              .runJavaScript(sendExtendedStyleSheetToJs(styleSheet));
        },
      )
      ..addJavaScriptChannel(
        'GetScriptlets',
        onMessageReceived: (message) async {
          debugLog("Passed Scriptlets arguments: ${message.message}");
          final scriptles = await _filterManager.getScriptlets(message.message);
          debugLog("Scriptlets: $scriptles");
          _webViewController.runJavaScript(sendScriptlesToJs(scriptles));
        },
      );
    /* _controllerCompleter.future.then((controller) {
      controller
        ..addJavaScriptHandler(
          handlerName: 'getStyleSheet',
          callback: (List<dynamic> arguments) {
            print("Passed arguments: $arguments");
            return _filterManager.getStyleSheet(arguments.first as String);
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'getExtendedCssStyleSheet',
          callback: (List<dynamic> arguments) {
            print("Passed arguments: $arguments");
            return _filterManager
                .getExtendedCssStyleSheet(arguments.first as String);
          },
        )
        ..addJavaScriptHandler(
          handlerName: 'getScriptlets',
          callback: (List<dynamic> arguments) {
            print("Passed arguments: $arguments");
            return _filterManager.getScriptlets(arguments.first as String);
          },
        )
        ..addJavaScriptHandler(
          handlerName: "hello",
          callback: (arguments) {
            print("Passed arguments: $arguments");
            return "hello from flutter";
          },
        );
    }); */
  }

  String _getUserAgent() {
    //todo: update user agent for each platform
    if (Platform.isAndroid) {
      return 'Mozilla/5.0 (Linux; Android 11) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36 MyFlutterApp/1.0';
    } else if (Platform.isIOS) {
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1 MyFlutterApp/1.0';
    } else {
      return 'Mozilla/5.0 (platform; vendor; version) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 MyFlutterApp/1.0';
    }
  }
}
