import 'package:flutter/material.dart';

import '../../../core/models/site_record.dart';
import '../../../core/errors/app_error_policy.dart';
import '../../reader/presentation/image_reader_page.dart';
import '../domain/image_content_loader.dart';

class ImageContentPage extends StatefulWidget {
  const ImageContentPage({
    super.key,
    required this.site,
    required this.contentUrl,
    required this.title,
    ImageContentLoader? loader,
  }) : _loader = loader;

  final SiteRecord site;
  final String contentUrl;
  final String title;
  final ImageContentLoader? _loader;

  @override
  State<ImageContentPage> createState() => _ImageContentPageState();
}

class _ImageContentPageState extends State<ImageContentPage> {
  late final ImageContentLoader _loader;
  Future<List<String>>? _future;

  @override
  void initState() {
    super.initState();
    _loader = widget._loader ?? RuntimeImageContentLoader();
    _future = _loader.loadImageUrls(
      site: widget.site,
      contentUrl: widget.contentUrl,
    );
  }

  void _retry() {
    setState(() {
      _future = _loader.loadImageUrls(
        site: widget.site,
        contentUrl: widget.contentUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} Images')),
      body: FutureBuilder<List<String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ImageErrorState(
              message: AppErrorPolicy.userMessage(
                error: snapshot.error!,
                fallback: 'Image parse failed. Please retry.',
              ),
              onRetry: _retry,
            );
          }
          final urls = snapshot.data ?? const <String>[];
          if (urls.isEmpty) {
            return const Center(child: Text('No image URLs found.'));
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ImageReaderPage(
                            title: widget.title,
                            imageUrls: urls,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chrome_reader_mode_outlined),
                    label: const Text('Open Reader (T11)'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: urls.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final url = urls[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text('${index + 1}. $url'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ImageErrorState extends StatelessWidget {
  const _ImageErrorState({required this.message, required this.onRetry});

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
              'Image parse failed',
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
