import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// FFI type definitions
typedef CreateParserNative = Pointer Function();
typedef CreateParser = Pointer Function();

typedef DestroyParserNative = Void Function(Pointer);
typedef DestroyParser = void Function(Pointer);

typedef LoadEasyListNative = Bool Function(Pointer, Pointer<Utf8>);
typedef LoadEasyList = bool Function(Pointer, Pointer<Utf8>);

typedef IsUrlBlockedNative = Bool Function(Pointer, Pointer<Utf8>);
typedef IsUrlBlocked = bool Function(Pointer, Pointer<Utf8>);

typedef GetAdSelectorsNative = Pointer<Utf8> Function(Pointer);
typedef GetAdSelectors = Pointer<Utf8> Function(Pointer);

typedef FreeStringNative = Void Function(Pointer<Utf8>);
typedef FreeString = void Function(Pointer<Utf8>);

// Structure to match C++ StringArray
base class StringArray extends Struct {
  external Pointer<Pointer<Utf8>> data;
  @Size()
  external int length;
}

// FFI type definitions for getBlockedDomains
typedef GetBlockedDomainsNative = StringArray Function(Pointer);
typedef GetBlockedDomains = StringArray Function(Pointer);

typedef FreeStringArrayNative = Void Function(StringArray);
typedef FreeStringArray = void Function(StringArray);

class EasyListParser {
  late final DynamicLibrary _lib;
  late final Pointer _parser;
  late final FreeString _freeString;
  late final FreeStringArray _freeStringArray;

  EasyListParser() {
    _lib = _loadLibrary();
    _parser = _createParser();
    _freeString = _lib
        .lookupFunction<FreeStringNative, FreeString>('easy_list_free_string');
    _freeStringArray =
        _lib.lookupFunction<FreeStringArrayNative, FreeStringArray>(
            'easy_list_free_string_array');
  }

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libadblocker_core.so');
    } else if (Platform.isIOS) {
      return DynamicLibrary.open('adblocker_core.framework/adblocker_core');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  Pointer _createParser() {
    final createParser = _lib.lookupFunction<CreateParserNative, CreateParser>(
        'easy_list_create_parser');
    return createParser();
  }

  bool loadFromFile(String filePath) {
    final loadEasyList = _lib.lookupFunction<LoadEasyListNative, LoadEasyList>(
        'easy_list_load_from_file');

    final pathPointer = filePath.toNativeUtf8();
    try {
      return loadEasyList(_parser, pathPointer);
    } finally {
      calloc.free(pathPointer);
    }
  }

  bool isUrlBlocked(String url) {
    final isUrlBlocked = _lib.lookupFunction<IsUrlBlockedNative, IsUrlBlocked>(
        'easy_list_is_url_blocked');

    final urlPointer = url.toNativeUtf8();
    try {
      return isUrlBlocked(_parser, urlPointer);
    } finally {
      calloc.free(urlPointer);
    }
  }

  List<String> getBlockedDomains() {
    final getBlockedDomains =
        _lib.lookupFunction<GetBlockedDomainsNative, GetBlockedDomains>(
            'easy_list_get_blocked_domains');

    final result = getBlockedDomains(_parser);
    try {
      return List<String>.generate(
        result.length,
        (i) => result.data[i].cast<Utf8>().toDartString(),
      );
    } finally {
      _freeStringArray(result);
    }
  }

  String getAdSelectors() {
    final getAdSelectors =
        _lib.lookupFunction<GetAdSelectorsNative, GetAdSelectors>(
            'easy_list_get_ad_selectors');

    final selectorsPointer = getAdSelectors(_parser);
    try {
      return selectorsPointer.cast<Utf8>().toDartString();
    } finally {
      _freeString(selectorsPointer);
    }
  }

  void dispose() {
    final destroyParser =
        _lib.lookupFunction<DestroyParserNative, DestroyParser>(
            'easy_list_destroy_parser');
    destroyParser(_parser);
  }
}
