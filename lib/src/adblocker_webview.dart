import 'package:adblocker_webview/src/adblocker_webview_controller.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/mapper/host_mapper.dart';
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
    this.options,
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
  final InAppWebViewGroupOptions? options;

  @override
  State<AdBlockerWebview> createState() => _AdBlockerWebviewState();
}

class _AdBlockerWebviewState extends State<AdBlockerWebview> {
  final _webViewKey = GlobalKey();
  InAppWebViewGroupOptions? _inAppWebViewOptions;

  @override
  void initState() {
    super.initState();
    _inAppWebViewOptions = widget.options ??
        InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(),
        );

    if (widget.shouldBlockAds) {
      _setContentBlockers();
    }
  }

  Future<void> _setContentBlockers() async {
    final contentBlockerList =
        mapHostToContentBlocker(widget.adBlockerWebviewController.bannedHost)
          ..addAll(mapHostToContentBlocker(widget.additionalHostsToBlock));
    _inAppWebViewOptions?.crossPlatform.contentBlockers = contentBlockerList;
  }

  void _clearContentBlockers() =>
      _inAppWebViewOptions?.crossPlatform.contentBlockers = [];

  @override
  void didUpdateWidget(AdBlockerWebview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldBlockAds) {
      _setContentBlockers();
    } else {
      _clearContentBlockers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      onWebViewCreated: widget.adBlockerWebviewController.setInternalController,
      initialUrlRequest: URLRequest(url: widget.url),
      initialOptions: _inAppWebViewOptions,
      onLoadStart: widget.onLoadStart,
      onLoadStop: widget.onLoadFinished,
      onLoadError: widget.onLoadError,
      onTitleChanged: widget.onTitleChanged,
      initialData: widget.initialHtmlData == null
          ? null
          : InAppWebViewInitialData(data: widget.initialHtmlData!),
    );
  }
}
