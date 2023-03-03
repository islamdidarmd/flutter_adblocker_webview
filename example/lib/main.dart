import 'package:adblocker_webview/adblocker_webview.dart';
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
  int _progress = 0;
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _adBlockerWebviewController.initialize();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _showBrowser
          ? Column(
              children: [
                LinearProgressIndicator(
                  value: _progress.toDouble(),
                ),
                Expanded(
                  child: AdBlockerWebviewWidget(
                    url: _textEditingController.text,
                    adBlockerWebviewController: _adBlockerWebviewController,
                    navigationDelegate: NavigationDelegate(
                      onProgress: (progress) {
                        setState(() {
                          _progress = progress;
                        });
                      },
                    ),
                    shouldBlockAds: true,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _textEditingController,
                  maxLines: 1,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showBrowser = true;
                    });
                  },
                  child: const Text("Go"),
                )
              ],
            ),
    );
  }
}
