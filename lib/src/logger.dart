import 'package:flutter/foundation.dart';

const _tag = 'AdBlockerWebView';

void debugLog(Object message) {
  if (kDebugMode) {
    print('$_tag: $message');
  }
}
