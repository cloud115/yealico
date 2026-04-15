import 'package:flutter/material.dart';

import '../../../core/models/site_record.dart';
import '../../../core/errors/app_error_policy.dart';
import '../../player/presentation/video_player_page.dart';
import '../domain/video_content_loader.dart';

class VideoContentPage extends StatefulWidget {
  const VideoContentPage({
    super.key,
    required this.site,
    required this.contentUrl,
    required this.title,
    VideoContentLoader? loader,
  }) : _loader = loader;

  final SiteRecord site;
  final String contentUrl;
  final String title;
  final VideoContentLoader? _loader;

  @override
  State<VideoContentPage> createState() => _VideoContentPageState();
}

class _VideoContentPageState extends State<VideoContentPage> {
  late final VideoContentLoader _loader;
  Future<String>? _future;

  @override
  void initState() {
    super.initState();
    _loader = widget._loader ?? RuntimeVideoContentLoader();
    _future = _loader.loadVideoUrl(
      site: widget.site,
      contentUrl: widget.contentUrl,
    );
  }

  void _retry() {
    setState(() {
      _future = _loader.loadVideoUrl(
        site: widget.site,
        contentUrl: widget.contentUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} Video URL')),
      body: FutureBuilder<String>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _VideoErrorState(
              message: AppErrorPolicy.userMessage(
                error: snapshot.error!,
                fallback: 'Video parse failed. Please retry.',
              ),
              onRetry: _retry,
            );
          }
          final videoUrl = snapshot.data;
          if (videoUrl == null || videoUrl.isEmpty) {
            return const Center(child: Text('No video URL found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parsed video URL',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SelectableText(videoUrl),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VideoPlayerPage(
                          title: widget.title,
                          videoUrl: videoUrl,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline),
                  label: const Text('Play Video (T13)'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VideoErrorState extends StatelessWidget {
  const _VideoErrorState({required this.message, required this.onRetry});

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
              'Video parse failed',
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
