import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/src/easylist_parser.dart';
import 'package:adblocker_core/src/filter.dart';
import 'package:adblocker_core/src/generated/generated_bindings.dart';
import 'package:ffi/ffi.dart';

class AdBlockerFilter implements Filter {
  AdBlockerFilter();

  late final EasyListParser easyListParser;

  @override
  Future<void> init() async {
    easyListParser = EasyListParser();
  }

  @override
  Future<void> dispose() async {
    easyListParser.dispose();
  }

  @override
  Future<bool> processFile(String filePath) async {
    return easyListParser.loadFromFile(filePath);
  }

  @override
  Future<List<String>> getBlockedUrls() async {
    return easyListParser.getBlockedDomains();
  }

  @override
  Future<bool> isAd(String url) async {
    return easyListParser.isUrlBlocked(url);
  }

  @override
  Future<String> getElementHidingSelectors() async {
    return easyListParser.getAdSelectors();
  }

  @override
  Future<List<String>> getUrlsToBlock() async {
    final result = _nativeLibrary!.adblocker_core_get_matching_rules(_core);
    final rules = <String>[];

    for (var i = 0; i < result.count; i++) {
        final rule = result.rules[i].cast<Utf8>().toDartString();
        rules.add(rule);
    }
    
    final rulesPtr = calloc<FilterRules>()..ref = result;
    _nativeLibrary!.filter_rules_free(rulesPtr);
    calloc.free(rulesPtr);
    
    return rules;
  }
}
