import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/config/app_config.dart';
import 'package:yealico/core/config/app_flavor.dart';
import 'package:yealico/core/config/app_runtime.dart';
import 'package:yealico/core/errors/app_error_policy.dart';
import 'package:yealico/core/errors/runtime_exceptions.dart';

void main() {
  tearDown(() {
    AppRuntime.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Yealico (Dev)',
        enableVerboseLogging: true,
      ),
    );
  });

  test('returns detailed message in dev mode', () {
    AppRuntime.initialize(
      const AppConfig(
        flavor: AppFlavor.dev,
        appName: 'Yealico (Dev)',
        enableVerboseLogging: true,
      ),
    );

    final message = AppErrorPolicy.userMessage(
      error: const FormatException('Invalid URL'),
      fallback: 'Generic error',
    );

    expect(message, 'Invalid URL');
  });

  test('returns generic message in prod mode', () {
    AppRuntime.initialize(
      const AppConfig(
        flavor: AppFlavor.prod,
        appName: 'Yealico',
        enableVerboseLogging: false,
      ),
    );

    final message = AppErrorPolicy.userMessage(
      error: const FormatException('Invalid URL'),
      fallback: 'Generic error',
    );

    expect(message, 'Generic error');
  });

  test('returns anti-bot and rate-limit messages even in prod mode', () {
    AppRuntime.initialize(
      const AppConfig(
        flavor: AppFlavor.prod,
        appName: 'Yealico',
        enableVerboseLogging: false,
      ),
    );

    expect(
      AppErrorPolicy.userMessage(
        error: const SiteVerificationPendingException(),
      ),
      '站点验证中，请检查网络或稍后重试',
    );
    expect(
      AppErrorPolicy.userMessage(
        error: const ProtectedImageBlockedException(),
      ),
      '图片防盗链拦截，请更新规则',
    );
    expect(
      AppErrorPolicy.userMessage(
        error: const DecryptScriptExecutionException(),
      ),
      '规则脚本执行异常',
    );
    expect(
      AppErrorPolicy.userMessage(error: const SiteRateLimitedException()),
      '站点限流，请稍后重试',
    );
  });
}
