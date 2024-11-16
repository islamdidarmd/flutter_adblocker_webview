import 'dart:async';
import 'dart:io';

import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/css.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A webview implementation of in Flutter that blocks most of the ads that
/// appear inside of the webpages.
class AdBlockerWebview extends StatefulWidget {
  const AdBlockerWebview({
    required this.adBlockerWebviewController,
    required this.shouldBlockAds,
    this.url,
    this.initialHtmlData,
    this.onLoadStart,
    this.onLoadFinished,
    this.onProgress,
    this.onLoadError,
    this.onTitleChanged,
    this.settings,
    this.additionalHostsToBlock = const [],
    super.key,
  }) : assert(
            (url == null && initialHtmlData != null) ||
                (url != null && initialHtmlData == null),
            'Both url and initialHtmlData can not be non null');

  /// Required: The initial [Uri] url that will be displayed in webview.
  final Uri? url;

  final String? initialHtmlData;

  /// Required: The controller for [AdBlockerWebview].
  /// See more at [AdBlockerWebviewController].
  final AdBlockerWebviewController adBlockerWebviewController;

  /// Required: Specifies whether to block or allow ads.
  final bool shouldBlockAds;

  /// Invoked when a page has started loading.
  final void Function(InAppWebViewController controller, Uri? uri)? onLoadStart;

  /// Invoked when a page has finished loading.
  final void Function(InAppWebViewController controller, Uri? uri)?
      onLoadFinished;

  /// Invoked when a page is loading to report the progress.
  final void Function(int progress)? onProgress;

  /// Invoked when the page title is changed.
  final void Function(InAppWebViewController controller, String? title)?
      onTitleChanged;

  final List<Host> additionalHostsToBlock;

  /// Invoked when a loading error occurred.
  final void Function(
    InAppWebViewController controller,
    Uri? url,
    int code,
    String message,
  )? onLoadError;

  /// Options for InAppWebView.
  final InAppWebViewSettings? settings;

  @override
  State<AdBlockerWebview> createState() => _AdBlockerWebviewState();
}

class _AdBlockerWebviewState extends State<AdBlockerWebview> {
  final _webViewKey = GlobalKey();
  InAppWebViewSettings? _settings;
  Completer<InAppWebViewController> _controllerCompleter = Completer();
  final _filterManager = FilterManager.create();

  @override
  void initState() {
    super.initState();
    _settings =
        widget.settings ?? InAppWebViewSettings(userAgent: _getUserAgent());
    InAppWebViewController.setWebContentsDebuggingEnabled(true);
    _setJavaScriptHandlers();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      onWebViewCreated: (controller) {
        _controllerCompleter.complete(controller);
        widget.adBlockerWebviewController.setInternalController(controller);
      },
      initialUrlRequest: URLRequest(url: WebUri.uri(widget.url!)),
      initialSettings: _settings,
      onLoadStart: (controller, uri) {
        controller.evaluateJavascript(source: elementHidingJS);
        widget.onLoadStart?.call(controller, uri);
      },
      onLoadStop: (controller, uri) {
        //controller.evaluateJavascript(source: helloJS);
        widget.onLoadFinished?.call(controller,uri);
      },
      onLoadError: widget.onLoadError,
      onTitleChanged: widget.onTitleChanged,
      initialData: widget.initialHtmlData == null
          ? null
          : InAppWebViewInitialData(data: widget.initialHtmlData!),
    );
  }

  void _setJavaScriptHandlers() {
    _controllerCompleter.future.then((controller) {
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
        )..addJavaScriptHandler(
          handlerName: "hello",
          callback: (arguments) {
            print("Passed arguments: $arguments");
            return "hello from flutter";
          },
      );
    });
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
