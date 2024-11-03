import 'package:adblocker_core_example/gen/assets.gen.dart';
import 'package:flutter/material.dart';

import 'package:adblocker_core/adblocker_core.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _adblockerCorePlugin = AdblockerCore();

  @override
  void initState() {
    super.initState();
    _initAdblockerCore();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _initAdblockerCore() async {
    final rawData = await DefaultAssetBundle.of(context).loadString(Assets.adguardBase);
    await _adblockerCorePlugin.init();
    await _adblockerCorePlugin.processRawData(rawData);

    await Future.delayed(const Duration(seconds: 1));
    final filtersCount = await _adblockerCorePlugin.getFilterCount();
    setState(() {
      _platformVersion = filtersCount.toString();
    });
    await _adblockerCorePlugin.dispose();
  }
}
