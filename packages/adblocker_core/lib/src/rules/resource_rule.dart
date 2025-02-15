class ResourceRule {
  ResourceRule({
    required this.url,
    this.isException = false,
  });
  final String url;
  final bool isException;
}
