import 'package:flutter/material.dart';

typedef ReaderImageBuilder =
    Widget Function(BuildContext context, String imageUrl, int index);

class ImageReaderPage extends StatefulWidget {
  const ImageReaderPage({
    super.key,
    required this.title,
    required this.imageUrls,
    this.imageBuilder,
  });

  final String title;
  final List<String> imageUrls;
  final ReaderImageBuilder? imageBuilder;

  @override
  State<ImageReaderPage> createState() => _ImageReaderPageState();
}

class _ImageReaderPageState extends State<ImageReaderPage> {
  late final PageController _controller;
  int _currentIndex = 0;
  final Set<int> _prefetched = <int>{};

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToNextPage() async {
    if (_currentIndex >= widget.imageUrls.length - 1) {
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
    String imageUrl,
    int index,
  ) {
    return InteractiveViewer(
      minScale: 1,
      maxScale: 4,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, _, _) => const Center(
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
    final total = widget.imageUrls.length;
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
                        widget.imageUrls[index],
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
                        color: Colors.black.withOpacity(0.6),
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
    _prefetchImage(index + 1);
    _prefetchImage(index - 1);
  }

  Future<void> _prefetchImage(int index) async {
    if (index < 0 || index >= widget.imageUrls.length) {
      return;
    }
    if (_prefetched.contains(index)) {
      return;
    }
    _prefetched.add(index);
    final provider = NetworkImage(widget.imageUrls[index]);
    try {
      await precacheImage(provider, context);
    } catch (_) {
      // Ignore prefetch failures and keep reader usable.
    }
  }
}
