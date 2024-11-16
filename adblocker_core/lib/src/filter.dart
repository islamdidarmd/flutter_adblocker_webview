abstract interface class Filter {
  Future<void> init();
  Future<void> dispose();
  Future<void> processRawData(String rawData);
  Future<int> getRulesCount();
  Future<bool> isAd(String url, String host, FilterOption filterOption);
  Future<String> getElementHidingSelector(String host);
  Future<List<String>> getExtendedCssSelectors(String host);
  Future<List<String>> getCssRules(String host);
  Future<List<String>> getScriptlets(String host);
}

enum FilterOption {
  unknown(0),
  script(1),
  image(2),
  css(3),
  xmlhttprequest(4),
  subdocument(6),
  font(7),
  media(8),
  ;

  const FilterOption(this.value);

  final int value;
}
