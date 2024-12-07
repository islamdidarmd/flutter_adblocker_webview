import 'dart:io';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_core_example/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _rulesCount = 0;
  String _rules = 'Unknown';
  final _adblockerFilter = AdBlockerFilter();

  @override
  void initState() {
    super.initState();
    _initFilter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Text('Activated rules count: $_rulesCount\n'),
              Text('Block List:\n$_rules'),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element, avoid_void_async
  void _initFilter() async {
    final rawData = await DefaultAssetBundle.of(context).load('assets/easylist.txt');

    final dir = await getApplicationSupportDirectory();
    final filePath = '${dir.path}/easylist.txt';
    final file = File(filePath);
    if(!file.existsSync()) {
      file.createSync();
    }
    file.writeAsBytesSync(rawData.buffer.asUint8List());

    await _adblockerFilter.init();
    await _adblockerFilter.processFile(filePath);

    await Future<void>.delayed(const Duration(seconds: 1));
    final blockedUrls = await _adblockerFilter.getBlockedUrls();
    setState(() {
      _rulesCount = blockedUrls.length;
      _rules = blockedUrls.join('\n');
    });
    await _adblockerFilter.dispose();
  }
}
