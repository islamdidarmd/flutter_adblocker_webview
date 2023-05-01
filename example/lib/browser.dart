import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:flutter/material.dart';

class Browser extends StatefulWidget {
  const Browser({
    super.key,
    required this.url,
    required this.controller,
    required this.shouldBlockAds,
  });

  final String url;
  final AdBlockerWebviewController controller;
  final bool shouldBlockAds;

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  int _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_progress > 0 && _progress < 100)
          LinearProgressIndicator(value: _progress / 100.0),
        Expanded(
          child: AdBlockerWebview(
            url: Uri.parse(widget.url),
            adBlockerWebviewController: widget.controller,
            onProgress: (progress) {
              setState(() {
                _progress = progress;
              });
            },
            shouldBlockAds: widget.shouldBlockAds,
          ),
        ),
      ],
    );
  }
}
