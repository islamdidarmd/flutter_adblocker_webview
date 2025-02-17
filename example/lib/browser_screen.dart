import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:flutter/material.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({
    required this.url,
    required this.shouldBlockAds,
    super.key,
  });

  final Uri url;
  final bool shouldBlockAds;

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  final _controller = AdBlockerWebviewController.instance;
  bool _canGoBack = false;
  String _appbarUrl = "";

  @override
  void initState() {
    super.initState();
    _appbarUrl = widget.url.host;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appbarUrl),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (await _controller.canGoBack()) {
                _controller.goBack();
              } else {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _canGoBack
                  ? () {
                      _controller.goBack();
                    }
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _controller.reload();
              },
            ),
          ],
        ),
        body: AdBlockerWebview(
          url: widget.url,
          shouldBlockAds: widget.shouldBlockAds,
          adBlockerWebviewController: _controller,
          onLoadStart: (url) {
            debugPrint('Started loading: $url');
          },
          onLoadFinished: (url) {
            debugPrint('Finished loading: $url');
            _updateNavigationState(url);
          },
          onLoadError: (url, code) {
            debugPrint('Error loading: $url (code: $code)');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading page: $code'),
                backgroundColor: Colors.red,
              ),
            );
          },
          onProgress: (progress) {
            debugPrint('Loading progress: $progress%');
          },
          onUrlChanged: (url) {
            _updateNavigationState(url);
          },
        ),
      ),
    );
  }

  Future<void> _updateNavigationState(String? url) async {
    if (!mounted) return;

    final canGoBack = await _controller.canGoBack();
    if (canGoBack != _canGoBack) {
      setState(() {
        _canGoBack = canGoBack;
        _appbarUrl = Uri.tryParse(url ?? "")?.host ?? "";
      });
    }
  }
}
