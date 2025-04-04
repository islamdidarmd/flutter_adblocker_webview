import 'dart:async';
import 'dart:io';

import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/block_resource_loading.dart';
import 'package:adblocker_webview/src/elem_hide.dart';
import 'package:adblocker_webview/src/logger.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
    this.onUrlChanged,
    super.key,
  }) : assert(
         url != null || initialHtmlData != null,
         'Either url or initialHtmlData must be provided',
       ),
       assert(
         !(url != null && initialHtmlData != null),
         'Cannot provide both url and initialHtmlData',
       );

  /// The initial [Uri] url that will be displayed in webview.
  /// Either this or [initialHtmlData] must be provided, but not both.
  final Uri? url;

  /// The initial HTML content to load in the webview.
  /// Either this or [url] must be provided, but not both.
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

  /// Invoked when a loading error occurred.
  final void Function(String? url, int code)? onLoadError;

  @override
  State<AdBlockerWebview> createState() => _AdBlockerWebviewState();
}

class _AdBlockerWebviewState extends State<AdBlockerWebview> {
  final _webViewKey = GlobalKey();
  late final WebViewController _webViewController;

  late Future<void> _depsFuture;
  final List<ResourceRule> _urlsToBlock = [];

  @override
  void initState() {
    super.initState();
    _depsFuture = _init();
  }

  Future<void> _init() async {
    _urlsToBlock
      ..clear()
      ..addAll(widget.adBlockerWebviewController.bannedResourceRules);

    _webViewController = WebViewController();
    await Future.wait([
      _webViewController.setOnConsoleMessage((message) {
        debugLog('[FLUTTER_WEBVIEW_LOG]: ${message.message}');
      }),
      _webViewController.setUserAgent(_getUserAgent()),
      _webViewController.setJavaScriptMode(JavaScriptMode.unrestricted),
    ]);

    _setNavigationDelegate();
    widget.adBlockerWebviewController.setInternalController(_webViewController);

    // Load either URL or HTML content
    if (widget.url != null) {
      unawaited(_webViewController.loadRequest(widget.url!));
    } else if (widget.initialHtmlData != null) {
      unawaited(_webViewController.loadHtmlString(widget.initialHtmlData!));
    }
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
          final shouldBlock = widget.adBlockerWebviewController
              .shouldBlockResource(request.url);
          if (shouldBlock) {
            debugLog('Blocking resource: ${request.url}');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) async {
          if (widget.shouldBlockAds) {
            // Inject resource blocking script as early as possible
            unawaited(
              _webViewController.runJavaScript(
                getResourceLoadingBlockerScript(_urlsToBlock),
              ),
            );
          }
          widget.onLoadStart?.call(url);
        },
        onPageFinished: (url) {
          if (widget.shouldBlockAds) {
            // Apply element hiding after page load
            final cssRules =
                widget.adBlockerWebviewController.getCssRulesForWebsite(url);
            unawaited(
              _webViewController.runJavaScript(generateHidingScript(cssRules)),
            );
          }

          widget.onLoadFinished?.call(url);
        },
        onProgress: (progress) => widget.onProgress?.call(progress),
        onHttpError:
            (error) => widget.onLoadError?.call(
              error.request?.uri.toString(),
              error.response?.statusCode ?? -1,
            ),
        onUrlChange: (change) => widget.onUrlChanged?.call(change.url),
      ),
    );
  }

  String _getUserAgent() {
    final osVersion = Platform.operatingSystemVersion;

    if (Platform.isAndroid) {
      // Chrome 120 is the latest stable version as of now
      return 'Mozilla/5.0 (Linux; Android $osVersion) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/120.0.0.0 Mobile Safari/537.36';
    } else if (Platform.isIOS) {
      // Convert iOS version format from 13.0.0 to 13_0_0
      final iosVersion = osVersion.replaceAll('.', '_');
      // iOS 17 with Safari 17 is the latest stable version
      return 'Mozilla/5.0 (iPhone; CPU iPhone OS $iosVersion like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) '
          'Version/17.0 Mobile/15E148 Safari/604.1';
    } else {
      // Default to latest Chrome for other platforms
      return 'Mozilla/5.0 ($osVersion) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/120.0.0.0 Safari/537.36';
    }
  }
}
