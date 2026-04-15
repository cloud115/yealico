import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void error({
    required String scope,
    required Object error,
    StackTrace? stackTrace,
  }) {
    debugPrint('[ERROR][$scope] $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
