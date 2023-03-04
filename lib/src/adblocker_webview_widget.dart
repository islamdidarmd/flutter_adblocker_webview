import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

import 'package:flutter/material.dart';

import 'adblocker_webview_controller.dart';
import 'domain/entity/host.dart';

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

  final String url;
  final AdBlockerWebviewController adBlockerWebviewController;
  final bool shouldBlockAds;
  final JavaScriptMode javaScriptMode;
  final Color backgroundColor;
  final FutureOr<NavigationDecision> Function(NavigationRequest request)?
      onNavigationRequest;
  final void Function(String url)? onPageStarted;
  final void Function(String url)? onPageFinished;
  final void Function(int progress)? onProgress;
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
