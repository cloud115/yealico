import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../features/rule_import/presentation/rule_import_page.dart';

class AppHomePage extends StatelessWidget {
  const AppHomePage({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(config.appName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Project Shell', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Flutter initialization is complete for Android and Web.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Flavor', value: config.flavorLabel),
                    _InfoRow(label: 'Targets', value: 'Android, Web'),
                    _InfoRow(
                      label: 'Verbose logging',
                      value: config.enableVerboseLogging
                          ? 'Enabled'
                          : 'Disabled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RuleImportPage(),
                  ),
                );
              },
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Import Rule (T04)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
