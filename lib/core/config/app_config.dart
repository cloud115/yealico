import 'app_flavor.dart';

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.enableVerboseLogging,
  });

  final AppFlavor flavor;
  final String appName;
  final bool enableVerboseLogging;

  bool get isDev => flavor == AppFlavor.dev;

  String get flavorLabel => switch (flavor) {
    AppFlavor.dev => 'DEV',
    AppFlavor.prod => 'PROD',
  };
}
