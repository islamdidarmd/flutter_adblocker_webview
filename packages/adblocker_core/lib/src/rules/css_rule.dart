class CSSRule {
  CSSRule({
    required this.domain,
    required this.selector,
    this.isException = false,
  });
  final List<String> domain;
  final String selector;
  final bool isException;
}
