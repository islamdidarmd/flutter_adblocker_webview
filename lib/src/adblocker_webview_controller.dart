import 'dart:collection';

import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:adblocker_webview/src/internal_adblocker_webview_controller.dart';

/// The controller for [AdBlockerWebview].
/// Below is and Example of getting a singleton instance:
/// ```dart
///    final _adBlockerWebviewController = AdBlockerWebviewController.instance;
/// ```
/// It's better to warm up the controller before displaying the webview.
/// It's possible to do that by:
/// ```dart
///   @override
///   void initState() {
///     super.initState();
///     _adBlockerWebviewController.initialize(config, []);
///     /// ... Other code here.
///   }
/// ```
///
///

///ignore_for_file: avoid-late-keyword
///ignore_for_file: avoid-non-null-assertion
abstract interface class AdBlockerWebviewController
    implements InternalWebviewController {
  static AdBlockerWebviewController? _instance;

  /// Returns an implementation of this class
  static AdBlockerWebviewController get instance {
    _instance ??= AdBlockerWebviewControllerImpl();
    return _instance!;
  }

  /// Initializes the controller
  Future<void> initialize(
    FilterConfig filterConfig,
    List<ResourceRule> additionalResourceRules,
  );

  /// Returns decision of if the webview can go back
  Future<bool> canGoBack();

  /// Returns decision of if he webview can go forward
  Future<bool> canGoForward();

  // Clears the cache of webview
  Future<void> clearCache();

  /// Returns the banned resource rules list.
  /// This list items are populated after calling the [initialize] method
  UnmodifiableListView<ResourceRule> get bannedResourceRules;

  // Returns the title of currently loaded webpage
  Future<String?> getTitle();

  // Loads the given url
  Future<void> loadUrl(String url);

  Future<void> loadData(String data, {String? baseUrl});

  /// Returns the css rules for the given url
  List<String> getCssRulesForWebsite(String url);

  /// Navigates webview to previous page
  Future<void> goBack();

  /// Navigates the webview to forward page
  Future<void> goForward();

  /// Returns decision of if the resource should be blocked
  bool shouldBlockResource(String url);

  /// Reloads the current page
  Future<void> reload();

  /// Runs the given script
  Future<void> runScript(String script);
}
