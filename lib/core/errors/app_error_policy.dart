import '../config/app_runtime.dart';
import 'runtime_exceptions.dart';

class AppErrorPolicy {
  AppErrorPolicy._();

  static String userMessage({
    required Object error,
    String fallback = 'Operation failed. Please try again.',
  }) {
    final typedMessage = _typedMessage(error);
    if (typedMessage != null) {
      return typedMessage;
    }
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

  static String? _typedMessage(Object error) {
    if (error is SiteVerificationPendingException) {
      return '站点验证中，请检查网络或稍后重试';
    }
    if (error is ProtectedImageBlockedException) {
      return '图片防盗链拦截，请更新规则';
    }
    if (error is DecryptScriptExecutionException) {
      return '规则脚本执行异常';
    }
    if (error is SiteRateLimitedException) {
      return '站点限流，请稍后重试';
    }
    return null;
  }
}
