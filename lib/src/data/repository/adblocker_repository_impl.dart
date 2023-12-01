import 'dart:convert';

import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdBlockerRepositoryImpl implements AdBlockerRepository {
  @override
  Future<List<Host>> fetchBannedHostList() async {
    const url =
        'https://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml&showintro=0';
    try {
      final response = await http.get(Uri.parse(url));

      return LineSplitter.split(response.body)
          .map((e) => Host(authority: e))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return [];
    }
  }
}
