import 'dart:async';
import 'dart:io';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/js.dart';
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
  late final WebViewController _webViewController;

  late Future<void> _depsFuture;
  final List<BlockRule> _urlsToBlock = [];

  final EasylistParser parser = EasylistParser();

  @override
  void initState() {
    super.initState();
    _depsFuture = _init();
  }

  Future<void> _init() async {
    await parser.init();
    _urlsToBlock
      ..clear()
      ..addAll(parser.getBlockRules());

    _webViewController = WebViewController();
    await _webViewController.setOnConsoleMessage(
      (message) {
        print('[FLUTTER_WEBVIEW_LOG]: ${message.message}');
      },
    );
    await _webViewController.setUserAgent(_getUserAgent());
    await _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    _setNavigationDelegate();
    widget.adBlockerWebviewController.setInternalController(_webViewController);
    unawaited(_webViewController.loadRequest(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _depsFuture,
      builder: (_, state) {
        if (state.hasError) {
          return Text('Error: ${state.error}');
        } else if (state.connectionState == ConnectionState.done) {
          return WebViewWidget(
            key: _webViewKey,
            controller: _webViewController,
          );
        } else if (state.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 45,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox();
      },
    );
  }

  void _setNavigationDelegate() {
    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) {
          final isThirdParty = Uri.parse(request.url).host != widget.url.host;
          final shouldBlock = _urlsToBlock.any((rule) =>
              rule.filter.contains(request.url) &&
              (rule.resourceType == ResourceType.any ||
                  rule.resourceType == ResourceType.script) &&
              (!rule.isThirdParty || isThirdParty) &&
              rule.matchesDomain(widget.url.host));

          if (shouldBlock) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) async {
          widget.onLoadStart?.call(url);
        },
        onPageFinished: (url) {
          unawaited(_webViewController
              .runJavaScript(getResourceLoadingBlockerScript(_urlsToBlock)));

          // Extract domain from full URL
          final domain = Uri.parse(url).host;
          final cssRules = parser.getCSSRulesForWebsite(domain);
          unawaited(
              _webViewController.runJavaScript(generateHidingScript(cssRules)));

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
