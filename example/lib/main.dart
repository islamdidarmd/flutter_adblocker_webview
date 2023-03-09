import 'package:adblocker_webview/adblocker_webview.dart';
import 'package:example/browser.dart';
import 'package:example/url_input.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _adBlockerWebviewController = AdBlockerWebviewController.instance;
  bool _showBrowser = false;
  bool _shouldBlockAds = false;
  String _url = "";

  @override
  void initState() {
    super.initState();
    _adBlockerWebviewController.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: _showBrowser
          ? FloatingActionButton(
              child: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _showBrowser = false;
                });
              },
            )
          : null,
      body: _showBrowser
          ? Browser(
              url: _url,
              controller: _adBlockerWebviewController,
              shouldBlockAds: _shouldBlockAds,
            )
          : UrlInput(
              onSubmit: (url) {
                setState(() {
                  _url = url;
                  _showBrowser = true;
                });
              },
              onBlockAdsStatusChange: (shouldBlockAds) {
                setState(() {
                  _shouldBlockAds = shouldBlockAds;
                });
              },
              shouldBlockAds: _shouldBlockAds,
            ),
    );
  }
}
