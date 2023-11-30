import 'dart:collection';

import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:adblocker_webview/src/adblocker_webview_controller_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';

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
}
