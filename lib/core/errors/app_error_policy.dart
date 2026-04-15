import '../config/app_runtime.dart';

class AppErrorPolicy {
  AppErrorPolicy._();

  static String userMessage({
    required Object error,
    String fallback = 'Operation failed. Please try again.',
  }) {
    final verbose = AppRuntime.config.enableVerboseLogging;
    if (verbose) {
      return _extractMessage(error);
    }
    return fallback;
  }

  static String _extractMessage(Object error) {
    if (error is FormatException) {
      return error.message;
    }
    if (error is ArgumentError) {
      final message = error.message;
      if (message != null && '$message'.isNotEmpty) {
        return '$message';
      }
    }
    if (error is Exception) {
      return error.toString();
    }
    return '$error';
  }
}
