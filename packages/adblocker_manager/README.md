# Adblocker Manager

A Flutter package that manages multiple ad-blocking filters for the adblocker_webview package.

## Features

- Support for multiple filter types (EasyList, AdGuard)
- Aggregates blocking decisions from multiple filters
- Combines CSS rules from all active filters
- Easy configuration and initialization

## Usage

```dart
// Create configuration
final config = FilterConfig(
  filterTypes: [FilterType.easyList, FilterType.adGuard],
);

// Initialize manager
final manager = AdblockFilterManager();
await manager.init(config);

// Check if resource should be blocked
final shouldBlock = manager.shouldBlockResource('https://example.com/ad.js');

// Get CSS rules for a website
final cssRules = manager.getCSSRulesForWebsite('example.com');
```

## Additional information

This package is part of the adblocker_webview_flutter project and works in conjunction with the adblocker_core package. 