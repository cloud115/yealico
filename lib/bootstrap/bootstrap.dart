import 'package:flutter/widgets.dart';

import '../app/app.dart';
import '../core/config/app_config.dart';
import '../core/config/app_runtime.dart';

void bootstrap(AppConfig config) {
  WidgetsFlutterBinding.ensureInitialized();
  AppRuntime.initialize(config);
  runApp(YealicoApp(config: config));
}
