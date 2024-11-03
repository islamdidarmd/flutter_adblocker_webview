import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/generated/generated_bindings.dart';

class AdblockerCore {
  AdblockerCore();
  late NativeLibrary _nativeLibrary;

  Future<void> init() async {
    if (Platform.isAndroid) {
      _nativeLibrary =
          NativeLibrary(DynamicLibrary.open('libadblocker_core.so'));
    } else if (Platform.isIOS) {
      _nativeLibrary = NativeLibrary(
          DynamicLibrary.open('adblocker_core.framework/adblocker_core'));
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Future<void> processRawData(String rawData) async {}

  Future<void> loadProcessedData(String processedData) async {}

  Future<int> getFilterCount() async {
    return 0;
  }

/*   Future<String> getPlatformVersion() async {
    NativeLibrary? _nativeLibrary;
    if (Platform.isAndroid) {
      _nativeLibrary = NativeLibrary(DynamicLibrary.open('libhello.so'));
    } else if (Platform.isIOS) {
      _nativeLibrary = NativeLibrary(DynamicLibrary.open('adblocker_core.framework/adblocker_core'));
    }
    final pointer = _nativeLibrary!.getPlatformVersion();
    return pointer.cast<Utf8>().toDartString();
  } */
}
