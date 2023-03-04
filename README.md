- A webview implementation of in Flutter that blocks most of the ads that appear inside of the webpages
- Current implementation is based on official `webview_flutter` packages. So, the features and limitation of that package
  is included

>On iOS the WebView widget is backed by a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).
On Android the WebView widget is backed by a [WebView](https://developer.android.com/reference/android/webkit/WebView).

|             | Android        | iOS   |
|-------------|----------------|-------|
| **Support** | SDK 19+ or 20+ | 11.0+ |

## Getting started
Add `adblocker_webview_flutter` as a [dependency in your pubspec.yaml file](https://pub.dev/packages/adblocker_webview_flutter/install).

## Usage
1. Acquire an instance of [AdBlockerWebviewController](https://pub.dev/documentation/adblocker_webview_flutter/latest/adblocker_webview_flutter/AdBlockerWebviewController-class.html])
```dart
  final _adBlockerWebviewController = AdBlockerWebviewController.instance;
```
It's better to warm up the controller before displaying the webview. It's possible to do that by
```dart
  @override
  void initState() {
    super.initState();
    _adBlockerWebviewController.initialize();
    /// ... Other code here.
  }
```

2. Add the [AdBlockerWebviewWidget](https://pub.dev/documentation/adblocker_webview_flutter/latest/adblocker_webview_flutter/AdBlockerWebviewWidget-class.html]) in widget tree
```dart
        AdBlockerWebviewWidget(
            url: "Valid url Here",
            adBlockerWebviewController: widget.controller,
            onProgress: (progress) {
              setState(() {
                _progress = progress;
              });
            },
            shouldBlockAds: true,
            /// Other params if required
          );
```
  Supported params of [AdBlockerWebviewWidget](https://pub.dev/documentation/adblocker_webview_flutter/latest/adblocker_webview_flutter/AdBlockerWebviewWidget-class.html]) are:
  ```dart
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
```
### Contribution
Contributions are welcome 😄. Please file an issue [Here](https://github.com/islamdidarmd/adblocker_webview_flutter/issues) if you want to include additional feature or found a bug!
