/// Base class for all filter-related exceptions
class FilterException implements Exception {
  /// Error message
  final String message;

  /// Optional error that caused this exception
  final Object? error;

  /// Creates a new [FilterException]
  FilterException(this.message, [this.error]);

  @override
  String toString() =>
      'FilterException: $message${error != null ? '\nCaused by: $error' : ''}';
}

/// Exception thrown when filter initialization fails
class FilterInitializationException extends FilterException {
  FilterInitializationException(String message, [Object? error])
      : super(message, error);
}
