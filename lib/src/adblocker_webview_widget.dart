import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';

import 'adblocker_webview_controller.dart';
import 'domain/entity/host.dart';

/// A webview implementation of in Flutter that blocks most of the ads that appear inside of the webpages.
class AdBlockerWebviewWidget extends StatefulWidget {

  const AdBlockerWebviewWidget({
    super.key,
    required this.url,
    required this.adBlockerWebviewController,
    required this.shouldBlockAds,
    this.javaScriptMode = JavaScriptMode.unrestricted,
    this.backgroundColor = const Color(0x00000000),
    this.onPageStarted,
    this.onNavigationRequest,
    this.onPageFinished,
    this.onProgress,
    this.onWebResourceError,
  });

  /// Required: The initial [String] url that will be displayed in webview.
  final String url;

  /// Required: The controller for [AdBlockerWebviewWidget]. See more at [AdBlockerWebviewController].
  final AdBlockerWebviewController adBlockerWebviewController;

  /// Required: Specifies whether to block or allow ads.
  final bool shouldBlockAds;

  /// Optional: Describes the state of JavaScript support in a given web view.
  /// See [JavaScriptMode].
  final JavaScriptMode javaScriptMode;

  /// Optional: backgroundColor of the webview.
  final Color backgroundColor;

  /// Invoked when a decision for a navigation request is pending.
  ///
  /// When a navigation is initiated by the WebView (e.g when a user clicks a
  /// link) this delegate is called and has to decide how to proceed with the
  /// navigation.
  final FutureOr<NavigationDecision> Function(NavigationRequest request)?
      onNavigationRequest;

  /// Invoked when a page has started loading.
  final void Function(String url)? onPageStarted;

  /// Invoked when a page has finished loading.
  final void Function(String url)? onPageFinished;

  /// Invoked when a page is loading to report the progress.
  final void Function(int progress)? onProgress;

  /// Invoked when a resource loading error occurred.
  final void Function(WebResourceError error)? onWebResourceError;

  @override
  State<AdBlockerWebviewWidget> createState() => _AdBlockerWebviewWidgetState();
}

class _AdBlockerWebviewWidgetState extends State<AdBlockerWebviewWidget> {
  final _webviewController = WebViewController();

  @override
  void initState() {
    super.initState();
    _webviewController
      ..setJavaScriptMode(widget.javaScriptMode)
      ..setBackgroundColor(widget.backgroundColor)
      ..setNavigationDelegate(_navigationDelegate)
      ..loadRequest(Uri.parse(widget.url));
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onPageStarted: widget.onPageStarted,
        onPageFinished: widget.onPageFinished,
        onProgress: widget.onProgress,
        onWebResourceError: widget.onWebResourceError,
      );

  FutureOr<NavigationDecision> _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.parse(request.url);

    if (widget.shouldBlockAds &&
        widget.adBlockerWebviewController.isAd(host: Host(domain: uri.host))) {
      return NavigationDecision.prevent;
    }

    return widget.onNavigationRequest?.call(request) ??
        NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webviewController);
  }
}
