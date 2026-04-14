import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import 'view/app_home_page.dart';

class YealicoApp extends StatelessWidget {
  const YealicoApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E847F),
    );

    return MaterialApp(
      title: config.appName,
      debugShowCheckedModeBanner: config.isDev,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F1EA),
      ),
      home: AppHomePage(config: config),
    );
  }
}
