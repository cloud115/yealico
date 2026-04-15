import 'package:flutter/material.dart';

import '../../../core/models/catalog_entry.dart';
import '../../../core/models/site_record.dart';
import '../../../core/errors/app_error_policy.dart';
import '../../detail/presentation/detail_list_page.dart';
import '../domain/catalog_loader.dart';

class SiteCatalogPage extends StatefulWidget {
  const SiteCatalogPage({super.key, required this.site, CatalogLoader? loader})
    : _loader = loader;

  final SiteRecord site;
  final CatalogLoader? _loader;

  @override
  State<SiteCatalogPage> createState() => _SiteCatalogPageState();
}

class _SiteCatalogPageState extends State<SiteCatalogPage> {
  late final CatalogLoader _loader;
  Future<List<CatalogEntry>>? _future;

  @override
  void initState() {
    super.initState();
    _loader = widget._loader ?? RuntimeCatalogLoader();
    _future = _loader.loadCatalog(widget.site);
  }

  void _retry() {
    setState(() {
      _future = _loader.loadCatalog(widget.site);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.site.siteName} Catalog')),
      body: FutureBuilder<List<CatalogEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: AppErrorPolicy.userMessage(
                error: snapshot.error!,
                fallback: 'Catalog load failed. Please retry.',
              ),
              onRetry: _retry,
            );
          }
          final entries = snapshot.data ?? const <CatalogEntry>[];
          if (entries.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _CatalogItemCard(
                entry: entry,
                onOpenDetail: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DetailListPage(
                        site: widget.site,
                        detailUrl: entry.detailUrl,
                        catalogTitle: entry.title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  const _CatalogItemCard({required this.entry, required this.onOpenDetail});

  final CatalogEntry entry;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('id: ${entry.id}'),
            Text('detailUrl: ${entry.detailUrl}'),
            if (entry.coverUrl != null) Text('cover: ${entry.coverUrl}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onOpenDetail,
              icon: const Icon(Icons.chevron_right),
              label: const Text('Open Details (T09)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No catalog items found for this site.'));
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Catalog load failed',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
