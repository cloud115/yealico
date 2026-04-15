import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/config/app_config.dart';
import 'package:yealico/core/config/app_flavor.dart';
import 'package:yealico/core/config/app_runtime.dart';
import 'package:yealico/core/errors/app_error_policy.dart';

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
}
