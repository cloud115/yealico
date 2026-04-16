import 'package:flutter/material.dart';

import '../../../core/models/content_resource.dart';
import '../domain/image_prefetch_scheduler.dart';

typedef ReaderImageBuilder = Widget Function(
    BuildContext context, ContentResource resource, int index);

class ImageReaderPage extends StatefulWidget {
  const ImageReaderPage({
    super.key,
    required this.title,
    required this.imageResources,
    this.imageBuilder,
    ImagePrefetchScheduler? prefetchScheduler,
  }) : _prefetchScheduler = prefetchScheduler;

  final String title;
  final List<ContentResource> imageResources;
  final ReaderImageBuilder? imageBuilder;
  final ImagePrefetchScheduler? _prefetchScheduler;

  @override
  State<ImageReaderPage> createState() => _ImageReaderPageState();
}

class _ImageReaderPageState extends State<ImageReaderPage> {
  late final PageController _controller;
  late final ImagePrefetchScheduler _prefetchScheduler;
  int _currentIndex = 0;
  final Set<int> _prefetched = <int>{};

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _prefetchScheduler = widget._prefetchScheduler ?? ImagePrefetchScheduler();
  }

  @override
  void dispose() {
    _prefetchScheduler.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToNextPage() async {
    if (_currentIndex >= widget.imageResources.length - 1) {
      return;
    }
    await _controller.nextPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  Future<void> _goToPrevPage() async {
    if (_currentIndex <= 0) {
      return;
    }
    await _controller.previousPage(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _handleTap(TapUpDetails details, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final dx = details.localPosition.dx;
    if (dx < width * 0.45) {
      _goToPrevPage();
      return;
    }
    if (dx > width * 0.55) {
      _goToNextPage();
      return;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.imageBuilder == null) {
      _prefetchAround(0);
    }
  }

  Widget _defaultImageBuilder(
    BuildContext context,
    ContentResource resource,
    int index,
  ) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Image.network(
        resource.url,
        headers: resource.headers,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Text(
            'Image load failed',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageResources.length;
    final imageBuilder = widget.imageBuilder ?? _defaultImageBuilder;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            key: const Key('reader_tap_layer'),
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) => _handleTap(details, constraints),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: total,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    if (widget.imageBuilder == null) {
                      _prefetchAround(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: imageBuilder(
                        context,
                        widget.imageResources[index],
                        index,
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Text(
                          '${_currentIndex + 1} / $total',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _prefetchAround(int index) {
    _prefetchImage(index - 2);
    _prefetchImage(index - 1);
    _prefetchImage(index + 1);
    _prefetchImage(index + 2);
  }

  void _prefetchImage(int index) {
    if (index < 0 || index >= widget.imageResources.length) {
      return;
    }
    if (_prefetched.contains(index)) {
      return;
    }
    _prefetched.add(index);
    final resource = widget.imageResources[index];
    _prefetchScheduler.schedule(() async {
      final provider = NetworkImage(resource.url, headers: resource.headers);
      try {
        await precacheImage(provider, context);
      } catch (_) {
        // Ignore prefetch failures and keep reader usable.
      }
    });
  }
}
