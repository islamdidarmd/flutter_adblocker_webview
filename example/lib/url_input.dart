import 'package:example/url_input_text_field.dart';
import 'package:flutter/material.dart';

class UrlInput extends StatefulWidget {
  const UrlInput({
    super.key,
    required this.onSubmit,
    required this.onBlockAdsStatusChange,
    required this.shouldBlockAds,
  });

  final Function(String url) onSubmit;
  final Function(bool shouldBlockAds) onBlockAdsStatusChange;
  final bool shouldBlockAds;

  @override
  State<UrlInput> createState() => _UrlInputState();
}

class _UrlInputState extends State<UrlInput> {
  final _textEditingController = TextEditingController();
  bool _shouldBlockAds = false;

  @override
  void initState() {
    super.initState();
    _shouldBlockAds = widget.shouldBlockAds;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UrlInputTextField(textEditingController: _textEditingController),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Block Ads"),
              Switch.adaptive(
                value: _shouldBlockAds,
                onChanged: (value) {
                  setState(() {
                    _shouldBlockAds = value;
                    widget.onBlockAdsStatusChange(value);
                  });
                },
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSubmit(_textEditingController.text);
            },
            child: const Text("Go"),
          )
        ],
      ),
    );
  }
}
