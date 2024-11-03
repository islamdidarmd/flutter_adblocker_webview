abstract interface class Filter {
  Future<void> init();
  Future<void> dispose();
  Future<void> processRawData(String rawData);
  Future<int> getRulesCount();
}
