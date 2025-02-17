import 'package:flutter/material.dart';

class UrlInputSection extends StatefulWidget {
  const UrlInputSection({
    required this.onUrlSubmitted,
    super.key,
  });

  final void Function(Uri url) onUrlSubmitted;

  @override
  State<UrlInputSection> createState() => _UrlInputSectionState();
}

class _UrlInputSectionState extends State<UrlInputSection> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const _predefinedUrls = [
    'https://www.theguardian.com',
    'https://www.nytimes.com',
    'https://www.cnn.com',
    'https://www.reddit.com',
    'https://www.youtube.com',
  ];

  final List<String> _recentUrls = [];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submitUrl() {
    if (_formKey.currentState?.validate() ?? false) {
      final url = _normalizeUrl(_urlController.text);
      _addToRecent(url.toString());
      widget.onUrlSubmitted(url);
    }
  }

  Uri _normalizeUrl(String input) {
    var url = input.trim().toLowerCase();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return Uri.parse(url);
  }

  void _addToRecent(String url) {
    setState(() {
      _recentUrls
        ..remove(url)
        ..insert(0, url);
      if (_recentUrls.length > 5) {
        _recentUrls.removeLast();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'Enter URL',
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _submitUrl,
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onFieldSubmitted: (_) => _submitUrl(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a URL';
                }
                try {
                  final url = _normalizeUrl(value);
                  if (!url.hasScheme || !url.hasAuthority) {
                    return 'Please enter a valid URL';
                  }
                } catch (e) {
                  return 'Invalid URL format';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Test URLs:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final url in _predefinedUrls)
                ActionChip(
                  label: Text(Uri.parse(url).host),
                  onPressed: () {
                    _urlController.text = url;
                    _submitUrl();
                  },
                ),
            ],
          ),
          if (_recentUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Recent URLs:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final url in _recentUrls)
                  InputChip(
                    label: Text(Uri.parse(url).host),
                    onPressed: () {
                      _urlController.text = url;
                      _submitUrl();
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        _recentUrls.remove(url);
                      });
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
