import 'package:webview_flutter/webview_flutter.dart';

abstract class InternalWebviewController {
  /// Sets WebViewController to be used in future
  /// Typically not to be used by third parties
  void setInternalController(WebViewController controller);
}
