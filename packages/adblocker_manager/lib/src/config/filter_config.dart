import 'filter_type.dart';

/// Configuration for the AdblockFilterManager
class FilterConfig {
  /// List of filter types to be used
  final List<FilterType> filterTypes;

  /// Creates a new [FilterConfig] instance
  ///
  /// [filterTypes] must not be empty
  FilterConfig({
    required this.filterTypes,
  }) : assert(
          filterTypes.isNotEmpty,
          'At least one filter type must be specified',
        );
}
