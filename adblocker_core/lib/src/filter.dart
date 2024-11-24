abstract interface class Filter {
  Future<void> init();
  Future<bool> processFile(String filePath);
  Future<List<String>> getBlockedUrls();
  Future<bool> isAd(String url);
  Future<String> getElementHidingSelectors();
  Future<void> dispose();
}
