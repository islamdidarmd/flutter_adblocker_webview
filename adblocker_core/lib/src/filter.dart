abstract interface class Filter {
  Future<void> init();
  Future<void> dispose();
  Future<void> processRawData(String rawData);
  Future<void> loadProcessedData(String processedData);
  Future<int> getRulesCount();
}
