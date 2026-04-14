import 'package:flutter/widgets.dart';

import '../app/app.dart';
import '../core/config/app_config.dart';

void bootstrap(AppConfig config) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(YealicoApp(config: config));
}
