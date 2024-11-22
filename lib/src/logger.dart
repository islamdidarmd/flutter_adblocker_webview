import 'package:flutter/foundation.dart';

const _logT = 'AdBlockerWebView';

void debugLog(Object message) {
  if (kDebugMode) {
    print('$_logT: $message');
  }
}
