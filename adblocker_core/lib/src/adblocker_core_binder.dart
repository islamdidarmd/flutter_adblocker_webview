import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/src/generated/generated_bindings.dart';
import 'package:ffi/ffi.dart';

class AdblockerCore {
  AdblockerCore();
  late AdBlockerCoreNative _nativeLibrary;
  late Pointer<AdBlockerCore> _core;

  Future<void> init() async {
    if (Platform.isAndroid) {
      _nativeLibrary =
          AdBlockerCoreNative(DynamicLibrary.open('libadblocker_core.so'));
    } else if (Platform.isIOS) {
      _nativeLibrary = AdBlockerCoreNative(
          DynamicLibrary.open('adblocker_core.framework/adblocker_core'));
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    _core = _nativeLibrary.adblocker_core_create();
  }

  Future<void> dispose() async {
    _nativeLibrary.adblocker_core_destroy(_core);
  }

  Future<void> processRawData(String rawData) async {
    final nativeRawData = rawData.toNativeUtf8();
    _nativeLibrary.adblocker_core_load_basic_data(
      _core,
      nativeRawData.cast<Char>(),
      0,
      false,
    );
    calloc.free(nativeRawData);
  }

  Future<void> loadProcessedData(String processedData) async {}

  Future<int> getFilterCount() async {
    return _nativeLibrary.adblocker_core_get_filters_count(_core);
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
