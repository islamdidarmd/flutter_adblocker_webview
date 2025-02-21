import 'package:adblocker_manager/adblocker_manager.dart';
import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:flutter/material.dart';

import 'browser_screen.dart';
import 'url_input_section.dart';

void main() async {
  await AdBlockerWebviewController.instance.initialize(
    FilterConfig(
      filterTypes: [FilterType.easyList, FilterType.adGuard],
    ),
    [],
  );
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdBlocker WebView Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _shouldBlockAds = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AdBlocker WebView Example'),
        actions: [
          Row(
            children: [
              const Text('Block Ads'),
              Switch(
                value: _shouldBlockAds,
                onChanged: (value) {
                  setState(() {
                    _shouldBlockAds = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter a URL to test ad blocking',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                UrlInputSection(
                  onUrlSubmitted: (url) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => BrowserScreen(
                          url: url,
                          shouldBlockAds: _shouldBlockAds,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
