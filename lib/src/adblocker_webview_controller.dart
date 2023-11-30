import 'dart:collection';

import 'package:adblocker_webview/src/data/repository/adblocker_repository_impl.dart';
import 'package:adblocker_webview/src/domain/entity/host.dart';
import 'package:adblocker_webview/src/domain/repository/adblocker_repository.dart';

/// The controller for [AdBlockerWebviewWidget].
/// Below is and Example of getting a singleton instance:
/// ```dart
///    final _adBlockerWebviewController = AdBlockerWebviewController.instance;
/// ```
/// It's better to warm up the controller before displaying the webview. It's possible to do that by:
/// ```dart
///   @override
///   void initState() {
///     super.initState();
///     _adBlockerWebviewController.initialize();
///     /// ... Other code here.
///   }
/// ```
///
///

///ignore_for_file: avoid-late-keyword
///ignore_for_file: avoid-non-null-assertion
class AdBlockerWebviewController {
  static AdBlockerWebviewController? _instance;

  late final AdBlockerRepository _repository;

  final _bannedHost = <Host>[];

  UnmodifiableListView<Host> get bannedHost =>
      UnmodifiableListView(_bannedHost);

  static AdBlockerWebviewController get instance {
    _instance ??= AdBlockerWebviewController._internal();

    return _instance!;
  }

  AdBlockerWebviewController._internal();

  Future<void> initialize() async {
    _repository = AdBlockerRepositoryImpl();
    final hosts = await _repository.fetchBannedHostList();
    _bannedHost
      ..clear()
      ..addAll(hosts);
  }
}
