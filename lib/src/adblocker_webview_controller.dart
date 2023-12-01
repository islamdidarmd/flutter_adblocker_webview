import 'dart:collection';

import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// The controller for [AdBlockerWebview].
/// Below is and Example of getting a singleton instance:
/// ```dart
///    final _adBlockerWebviewController = AdBlockerWebviewController.instance;
/// ```
/// It's better to warm up the controller before displaying the webview. It's possible to do that by:
/// ```dart
///   @override
///   void initState() {
///     super.initState();
///     _adBlockerWebviewController.initialize();
///     /// ... Other code here.
///   }
/// ```
///
///

///ignore_for_file: avoid-late-keyword
///ignore_for_file: avoid-non-null-assertion
abstract class AdBlockerWebviewController {
  static AdBlockerWebviewController? _instance;

  /// Returns an implementation of this class
  static AdBlockerWebviewController get instance {
    _instance ??= AdBlockerWebviewControllerImpl();
    return _instance!;
  }

  /// Returns the banned host list.
  /// This list items are populated after calling the [initialize] method
  UnmodifiableListView<Host> get bannedHost;

  /// Initializes the controller
  Future<void> initialize();

  /// Sets inAppWebviewController to be used in future
  /// Typically not to be used by third parties
  void setInternalController(InAppWebViewController controller);

  /// Returns decision of if the webview can go back
  Future<bool> canGoBack();

  /// Navigates webview to previous page
  Future<void> goBack();

  /// Returns decision of if he webview can go forward
  Future<bool> canGoForward();

  /// Navigates the webview to forward page
  Future<void> goForward();

  /// Reloads the current page
  Future<void> reload();
}
