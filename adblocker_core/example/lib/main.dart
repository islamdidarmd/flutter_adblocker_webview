import 'package:adblocker_core/adblocker_core.dart';
import 'package:adblocker_core_example/gen/assets.gen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _rulesCount = 'Unknown';
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
        body: Center(
          child: Text('Activated rules count: $_rulesCount\n'),
        ),
      ),
    );
  }

  // ignore: unused_element, avoid_void_async
  void _initFilter() async {
    final rawData =
        await DefaultAssetBundle.of(context).loadString(Assets.adguardBase);
    await _adblockerFilter.init();
    await _adblockerFilter.processRawData(rawData);

    await Future<void>.delayed(const Duration(seconds: 1));
    final rulesCount = await _adblockerFilter.getRulesCount();
    setState(() {
      _rulesCount = rulesCount.toString();
    });
    await _adblockerFilter.dispose();
  }
}
