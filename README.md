[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

- A webview implementation of in Flutter that blocks most of the ads that appear inside of the webpages
- Current implementation is based on official `flutter_inappwebview` packages. So, the features and limitation of that package
  is included

>On iOS the WebView widget is backed by a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).
On Android the WebView widget is backed by a [WebView](https://developer.android.com/reference/android/webkit/WebView).

|             | Android        | iOS   |
|-------------|----------------|-------|
| **Support** | SDK 19+ or 20+ | 11.0+ |

## Getting started
Add `adblocker_webview` as a [dependency](https://pub.dev/packages/adblocker_webview/install) in your pubspec.yaml file.

## Usage
1. Acquire an instance of [AdBlockerWebviewController](https://pub.dev/documentation/adblocker_webview/latest/adblocker_webview/AdBlockerWebviewController-class.html)
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

2. Add the [AdBlockerWebview](https://pub.dev/documentation/adblocker_webview/latest/adblocker_webview/AdBlockerWebview-class.html) in widget tree
```dart
        AdBlockerWebview(
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
  Supported params of [AdBlockerWebview](https://pub.dev/documentation/adblocker_webview/latest/adblocker_webview/AdBlockerWebview-class.html]) are:
  ```dart
  const AdBlockerWebview({
      super.key,
      required this.url,
      required this.adBlockerWebviewController,
      required this.shouldBlockAds,
      this.onLoadStart,
      this.onLoadFinished,
      this.onProgress,
      this.onLoadError,
      this.onTitleChanged,
      this.options,
  });
```
### Contribution
Contributions are welcome 😄. Please file an issue [here](https://github.com/islamdidarmd/flutter_adblocker_webview/issues) if you want to include additional feature or found a bug!
#### Guide
1. Create an issue first to make sure your request is not a duplicate one
2. Create a fork of the repository (If it's your first contribution)
3. Make a branch from `develop`
4. Branch name should indicate the contribution type
  - `feature/**` for new feature
  - `bugfix/**` for a bug fix
5. Raise a PR against the `develop` branch