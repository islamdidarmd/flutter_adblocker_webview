import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/generated/generated_bindings.dart';
import 'package:ffi/ffi.dart';

class AdblockerCore {
  AdblockerCore();

  Future<void> loadFilterData() async {}

  Future<String> getPlatformVersion() async {
    NativeLibrary? _nativeLibrary;
    if (Platform.isAndroid) {
      _nativeLibrary = NativeLibrary(DynamicLibrary.open('libhello.so'));
    } else if (Platform.isIOS) {
      _nativeLibrary = NativeLibrary(DynamicLibrary.open('adblocker_core.framework/adblocker_core'));
    }
    final pointer = _nativeLibrary!.getPlatformVersion();
    return pointer.cast<Utf8>().toDartString();
  }
}
