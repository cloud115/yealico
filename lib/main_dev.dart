import 'bootstrap/bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/config/app_flavor.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.dev,
      appName: 'Yealico (Dev)',
      enableVerboseLogging: true,
    ),
  );
}
