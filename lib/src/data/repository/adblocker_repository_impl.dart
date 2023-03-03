import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entity/host.dart';
import '../../domain/repository/adblocker_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AdBlockerRepository)
class AdBlockerRepositoryImpl implements AdBlockerRepository {
  @override
  Future<List<Host>> fetchBannedHostList() async {
    final url =
        "https://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml&showintro=0";
    try {
      final response = await http.get(Uri.parse(url));

      return LineSplitter.split(response.body)
          .map((e) => Host(domain: e))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }

      return [];
    }
  }
}
