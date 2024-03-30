import 'dart:convert';

import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AdBlockerRepositoryImpl implements AdBlockerRepository {
  final _url =
      'https://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml&showintro=0';

  @override
  Future<List<Host>> fetchBannedHostList() async {
    try {
      final response = await _getDataWithCache(_url);

      return LineSplitter.split(response)
          .map((e) => Host(authority: e))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return [];
    }
  }

  Future<String> _getDataWithCache(String url) async {
    final cacheManager = DefaultCacheManager();
    final file = await cacheManager.getSingleFile(url);
    return file.readAsString();
  }
}
