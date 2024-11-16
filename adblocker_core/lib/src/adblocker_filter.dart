import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/src/filter.dart';
import 'package:adblocker_core/src/generated_bindings.dart';
import 'package:ffi/ffi.dart';

class AdBlockerFilter implements Filter {
  AdBlockerFilter();
  AdBlockerCoreNative? _nativeLibrary;
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
    _core = _nativeLibrary!.adblocker_core_create();
  }

  @override
  Future<void> dispose() async {
    _nativeLibrary?.adblocker_core_destroy(_core);
  }

  @override
  Future<void> processRawData(String rawData) async {
    final nativeRawData = rawData.toNativeUtf8();
    _nativeLibrary!.adblocker_core_load_basic_data(
      _core,
      nativeRawData.cast<Char>(),
      0,
      false,
    );
    calloc.free(nativeRawData);
  }

  @override
  Future<int> getRulesCount() async {
    return _nativeLibrary!.adblocker_core_get_filters_count(_core);
  }

  @override
  Future<bool> isAd(String url, String host, FilterOption filterOption) async {
    final result = _nativeLibrary!.adblocker_core_matches(
      _core,
      url.toNativeUtf8().cast<Char>(),
      host.toNativeUtf8().cast<Char>(),
      filterOption.value,
    );
    return result.should_block;
  }

  @override
  Future<String> getElementHidingSelector(String host) async {
    final nativeResult =
        _nativeLibrary!.adblocker_core_get_element_hiding_selectors(
      _core,
      host.toNativeUtf8().cast<Char>(),
    );
    final result = nativeResult.cast<Utf8>().toDartString();
    calloc.free(nativeResult);
    return result;
  }

  @override
  Future<List<String>> getExtendedCssSelectors(String host) async {
    final nativeResult =
        _nativeLibrary!.adblocker_core_get_extended_css_selectors(
      _core,
      host.toNativeUtf8().cast<Char>(),
    );
    final result = <String>[];

    for (var i = 0; i < nativeResult.length; i++) {
      final pointer = nativeResult.data[i];
      result.add(pointer.cast<Utf8>().toDartString());
    }

    calloc.free(nativeResult.data);
    return result;
  }

  @override
  Future<List<String>> getCssRules(String host) async {
    final nativeResult =
        _nativeLibrary!.adblocker_core_get_css_rules(
      _core,
      host.toNativeUtf8().cast<Char>(),
    );
    final result = <String>[];

    for (var i = 0; i < nativeResult.length; i++) {
      final pointer = nativeResult.data[i];
      result.add(pointer.cast<Utf8>().toDartString());
    }

    calloc.free(nativeResult.data);
    return result;
  }

  @override
  Future<List<String>> getScriptlets(String host) async {
    final nativeResult =
        _nativeLibrary!.adblocker_core_get_scriptlets(
      _core,
      host.toNativeUtf8().cast<Char>(),
    );
    final result = <String>[];

    for (var i = 0; i < nativeResult.length; i++) {
      final pointer = nativeResult.data[i];
      result.add(pointer.cast<Utf8>().toDartString());
    }

    calloc.free(nativeResult.data);
    return result;
  }
}
