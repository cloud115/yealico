import 'package:flutter/material.dart';

import '../../../core/models/content_type.dart';
import '../../../core/models/detail_entry.dart';
import '../../../core/models/site_record.dart';
import '../../../core/errors/app_error_policy.dart';
import '../../content/presentation/image_content_page.dart';
import '../../content/presentation/video_content_page.dart';
import '../domain/detail_loader.dart';

class DetailListPage extends StatefulWidget {
  const DetailListPage({
    super.key,
    required this.site,
    required this.detailUrl,
    required this.catalogTitle,
    DetailLoader? loader,
  }) : _loader = loader;

  final SiteRecord site;
  final String detailUrl;
  final String catalogTitle;
  final DetailLoader? _loader;

  @override
  State<DetailListPage> createState() => _DetailListPageState();
}

class _DetailListPageState extends State<DetailListPage> {
  late final DetailLoader _loader;
  Future<List<DetailEntry>>? _future;

  @override
  void initState() {
    super.initState();
    _loader = widget._loader ?? RuntimeDetailLoader();
    _future = _loader.loadDetail(
      site: widget.site,
      detailUrl: widget.detailUrl,
    );
  }

  void _retry() {
    setState(() {
      _future = _loader.loadDetail(
        site: widget.site,
        detailUrl: widget.detailUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.catalogTitle} Details')),
      body: FutureBuilder<List<DetailEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _DetailErrorState(
              message: AppErrorPolicy.userMessage(
                error: snapshot.error!,
                fallback: 'Detail load failed. Please retry.',
              ),
              onRetry: _retry,
            );
          }
          final entries = snapshot.data ?? const <DetailEntry>[];
          if (entries.isEmpty) {
            return const Center(child: Text('No detail items found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _DetailItemCard(
                entry: entry,
                actionLabel: widget.site.contentType == ContentType.video
                    ? 'Parse Video URL (T12)'
                    : 'Parse Images (T10)',
                actionEnabled: true,
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          widget.site.contentType == ContentType.video
                          ? VideoContentPage(
                              site: widget.site,
                              contentUrl: entry.url,
                              title: entry.title,
                            )
                          : ImageContentPage(
                              site: widget.site,
                              contentUrl: entry.url,
                              title: entry.title,
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

class _DetailItemCard extends StatelessWidget {
  const _DetailItemCard({
    required this.entry,
    required this.actionLabel,
    required this.actionEnabled,
    required this.onAction,
  });

  final DetailEntry entry;
  final String actionLabel;
  final bool actionEnabled;
  final VoidCallback? onAction;

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
            Text('url: ${entry.url}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: actionEnabled ? onAction : null,
              icon: const Icon(Icons.image_outlined),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.message, required this.onRetry});

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
              'Detail load failed',
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
