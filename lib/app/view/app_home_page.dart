import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/models/content_type.dart';
import '../../core/models/rule_import_request.dart';
import '../../core/models/site_record.dart';
import '../../core/errors/app_error_policy.dart';
import '../../core/logging/app_logger.dart';
import '../../features/catalog/presentation/site_catalog_page.dart';
import '../../features/rule_import/domain/rule_import_mapper.dart';
import '../../features/rule_import/presentation/rule_import_page.dart';

class AppHomePage extends StatefulWidget {
  const AppHomePage({super.key, required this.config});

  final AppConfig config;

  @override
  State<AppHomePage> createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  final _mapper = const RuleImportMapper();
  final List<SiteRecord> _sites = <SiteRecord>[];

  Future<void> _openImportPage() async {
    final request = await Navigator.of(context).push<RuleImportRequest>(
      MaterialPageRoute<RuleImportRequest>(
        builder: (_) => const RuleImportPage(),
      ),
    );
    if (!mounted || request == null) {
      return;
    }

    try {
      final site = _mapper.toSiteRecord(request);
      setState(() {
        final index = _sites.indexWhere((s) => s.siteId == site.siteId);
        if (index >= 0) {
          _sites[index] = site;
        } else {
          _sites.add(site);
        }
      });
    } on FormatException catch (e, st) {
      AppLogger.error(
        scope: 'AppHomePage.importMapping',
        error: e,
        stackTrace: st,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorPolicy.userMessage(
              error: e,
              fallback: 'Import result is invalid.',
            ),
          ),
        ),
      );
    } on ArgumentError catch (e, st) {
      AppLogger.error(
        scope: 'AppHomePage.importMapping',
        error: e,
        stackTrace: st,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppErrorPolicy.userMessage(
              error: e,
              fallback: 'Import result is invalid.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.config.appName)),
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
                    _InfoRow(label: 'Flavor', value: widget.config.flavorLabel),
                    _InfoRow(label: 'Targets', value: 'Android, Web'),
                    _InfoRow(
                      label: 'Verbose logging',
                      value: widget.config.enableVerboseLogging
                          ? 'Enabled'
                          : 'Disabled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openImportPage,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Import Rule (T04)'),
            ),
            const SizedBox(height: 20),
            Text(
              'Imported Sites (${_sites.length})',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _sites.isEmpty
                  ? const _EmptySitesState()
                  : ListView.separated(
                      itemCount: _sites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final site = _sites[index];
                        return _SiteCard(
                          site: site,
                          onOpenCatalog: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => SiteCatalogPage(site: site),
                              ),
                            );
                          },
                        );
                      },
                    ),
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

class _EmptySitesState extends StatelessWidget {
  const _EmptySitesState();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No site has been imported yet. Use "Import Rule (T04)" to add one.',
        ),
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  const _SiteCard({required this.site, required this.onOpenCatalog});

  final SiteRecord site;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(site.siteName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('siteId: ${site.siteId}'),
            Text('contentType: ${site.contentType.value}'),
            Text('baseUrl: ${site.baseUrl}'),
            Text('ruleVersion: ${site.rule.version}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpenCatalog,
              icon: const Icon(Icons.list_alt),
              label: const Text('Open Catalog (T08)'),
            ),
          ],
        ),
      ),
    );
  }
}
