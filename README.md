[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)

# AdBlocker WebView Flutter

A Flutter WebView implementation that blocks ads and trackers using EasyList and AdGuard filter lists.

## Features

- 🚫 Basic ad and tracker blocking using EasyList and AdGuard filters
- 🌐 Supports both URL and HTML content loading
- 🔄 Navigation control (back, forward, refresh)
- 📱 User agent strings for Android and iOS
- ⚡ Early resource blocking for better performance
- 🎯 Domain-based filtering and element hiding
- 🔍 Detailed logging of blocked resources
- 💉 Custom JavaScript injection support

## Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  adblocker_webview: ^1.0.0
```

### Basic Usage

```dart
import 'package:adblocker_webview/adblocker_webview.dart';

// Initialize the controller (preferably in main())
void main() async {
  await AdBlockerWebviewController.instance.initialize();
  runApp(MyApp());
}

// Use in your widget
class MyWebView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdBlockerWebview(
      url: Uri.parse('https://example.com'),
      shouldBlockAds: true,
      adBlockerWebviewController: AdBlockerWebviewController.instance,
      onLoadStart: (url) => print('Started loading: $url'),
      onLoadFinished: (url) => print('Finished loading: $url'),
      onLoadError: (url, code) => print('Error: $code'),
      onProgress: (progress) => print('Progress: $progress%'),
    );
  }
}
```

### Loading HTML Content

```dart
AdBlockerWebview(
  initialHtmlData: '<html><body>Hello World!</body></html>',
  shouldBlockAds: true,
  adBlockerWebviewController: AdBlockerWebviewController.instance,
)
```

### Navigation Control

```dart
final controller = AdBlockerWebviewController.instance;

// Check if can go back
if (await controller.canGoBack()) {
  controller.goBack();
}

// Reload page
controller.reload();

// Execute JavaScript
controller.runJavaScript('console.log("Hello from Flutter!")');
```

## Configuration

The WebView can be configured with various options:

```dart
AdBlockerWebview(
  url: Uri.parse('https://example.com'),
  shouldBlockAds: true,  // Enable/disable ad blocking
  adBlockerWebviewController: AdBlockerWebviewController.instance,
  onLoadStart: (url) {
    // Page started loading
  },
  onLoadFinished: (url) {
    // Page finished loading
  },
  onProgress: (progress) {
    // Loading progress (0-100)
  },
  onLoadError: (url, code) {
    // Handle loading errors
  },
  onUrlChanged: (url) {
    // URL changed
  },
);
```

## Features in Detail

### Ad Blocking
- Basic support for EasyList and AdGuard filter lists
- Blocks common ad resources before they load
- Hides ad elements using CSS rules
- Supports exception rules for whitelisting

### Resource Blocking
- Blocks common trackers and unwanted resources
- Early blocking for better performance
- Basic domain-based filtering
- Exception handling for whitelisted domains

### Element Hiding
- Hides common ad containers and placeholders
- CSS-based element hiding
- Basic domain-specific rules support
- Batch processing for better performance

## Migration Guide

### Migrating from 1.2.0 to 2.0.0-beta

#### Breaking Changes

1. **Controller Initialization**
   ```dart
   // Old (1.2.0)
   final controller = AdBlockerWebviewController();
   await controller.initialize();

   // New (2.0.0-beta)
   await AdBlockerWebviewController.instance.initialize(
     FilterConfig(
       filterTypes: [FilterType.easyList, FilterType.adGuard],
     ),
   );
   ```

2. **URL Parameter Type**
   ```dart
   // Old (1.2.0)
   AdBlockerWebview(
     url: "https://example.com",
     // ...
   )

   // New (2.0.0-beta)
   AdBlockerWebview(
     url: Uri.parse("https://example.com"),
     // ...
   )
   ```

3. **Filter Configuration**
   ```dart
   // Old (1.2.0)
   AdBlockerWebview(
   //.. other params
     additionalHostsToBlock: ['ads.example.com'],
   );

   // New (2.0.0-beta)
   // Use FilterConfig for configuration
   await AdBlockerWebviewController.instance.initialize(
     FilterConfig(
       filterTypes: [FilterType.easyList, FilterType.adGuard],
     ),
   );
   ```

4. **Event Handlers**
   ```dart
   // Old (1.2.0)
   onTitleChanged: (title) { ... }

   // New (2.0.0-beta)
   // Use onUrlChanged instead
   onUrlChanged: (url) { ... }
   ```

#### Deprecated Features
- `additionalHostsToBlock` parameter is removed
- Individual controller instances are replaced with singleton
- `onTitleChanged` callback is replaced with `onUrlChanged`

#### New Features
- Singleton controller pattern for better resource management
- Structured filter configuration using `FilterConfig`
- Improved type safety with `Uri` for URLs
- Enhanced filter list parsing and management
- Better performance through early resource blocking

#### Steps to Migrate
1. Update the package version in `pubspec.yaml`:
   ```yaml
   dependencies:
     adblocker_webview: ^2.0.0-beta
   ```

2. Replace controller initialization with singleton pattern
3. Update URL parameters to use `Uri` instead of `String`
4. Replace deprecated callbacks with new ones
5. Update filter configuration to use `FilterConfig`
6. Test the application thoroughly after migration

## Contributing

We welcome contributions to improve the ad-blocking capabilities! Here's how you can help:

### Getting Started
1. Fork the repository
2. Create a new branch from `main` for your feature/fix
   - Use `feature/` prefix for new features
   - Use `fix/` prefix for bug fixes
   - Use `docs/` prefix for documentation changes
3. Make your changes
4. Write/update tests if needed
5. Update documentation if needed
6. Run tests and ensure they pass
7. Submit a pull request

### Before Submitting
- Check that your code follows our style guide (see analysis badge)
- Write clear commit messages
- Include tests for new features
- Update documentation if needed
- Verify all tests pass

### Pull Request Process
1. Create an issue first to discuss major changes
2. Update the README.md if needed
3. Update the CHANGELOG.md following semantic versioning
4. The PR will be reviewed by maintainers
5. Once approved, it will be merged

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use the provided analysis options
- Run `dart format` before committing

## License

This project is licensed under the BSD-3-Clause License - see the LICENSE file for details.
