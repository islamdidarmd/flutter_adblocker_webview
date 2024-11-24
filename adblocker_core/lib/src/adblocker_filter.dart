import 'dart:ffi';
import 'dart:io';

import 'package:adblocker_core/src/easylist_parser.dart';
import 'package:adblocker_core/src/filter.dart';
import 'package:adblocker_core/src/generated_bindings.dart';
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
}
