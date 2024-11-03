import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/src/filter.dart';
import 'package:adblocker_core/src/generated_bindings.dart';
import 'package:ffi/ffi.dart';

class AdBlockerFilter implements Filter {
  AdBlockerFilter();
  late AdBlockerCoreNative _nativeLibrary;
  late Pointer<AdBlockerCore> _core;

  @override
  Future<void> init() async {
    if (Platform.isAndroid) {
      _nativeLibrary =
          AdBlockerCoreNative(DynamicLibrary.open('libadblocker_core.so'));
    } else if (Platform.isIOS) {
      _nativeLibrary = AdBlockerCoreNative(
        DynamicLibrary.open('adblocker_core.framework/adblocker_core'),
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    _core = _nativeLibrary.adblocker_core_create();
  }

  @override
  Future<void> dispose() async {
    _nativeLibrary.adblocker_core_destroy(_core);
  }

  @override
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

  @override
  Future<void> loadProcessedData(String processedData) async {
    final nativeProcessedData = processedData.toNativeUtf8();
    _nativeLibrary.adblocker_core_load_processed_data(
      _core,
      nativeProcessedData.cast<Char>(),
      0,
    );
    calloc.free(nativeProcessedData);
  }

  @override
  Future<int> getRulesCount() async {
    return _nativeLibrary.adblocker_core_get_filters_count(_core);
  }
}
