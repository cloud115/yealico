import 'bootstrap/bootstrap.dart';
import 'core/config/app_config.dart';
import 'core/config/app_flavor.dart';

void main() {
  bootstrap(
    const AppConfig(
      flavor: AppFlavor.prod,
      appName: 'Yealico',
      enableVerboseLogging: false,
    ),
  );
}
