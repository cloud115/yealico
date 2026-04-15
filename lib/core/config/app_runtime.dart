import 'app_config.dart';
import 'app_flavor.dart';

class AppRuntime {
  AppRuntime._();

  static AppConfig _config = const AppConfig(
    flavor: AppFlavor.dev,
    appName: 'Yealico (Dev)',
    enableVerboseLogging: true,
  );

  static AppConfig get config => _config;

  static void initialize(AppConfig config) {
    _config = config;
  }
}
