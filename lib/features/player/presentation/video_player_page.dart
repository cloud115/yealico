import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/errors/app_error_policy.dart';
import '../../../core/logging/app_logger.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.title,
    required this.videoUrl,
  });

  final String title;
  final String videoUrl;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null || !uri.isAbsolute) {
      setState(() {
        _error = AppErrorPolicy.userMessage(
          error: const FormatException('Invalid video URL.'),
          fallback: 'Video cannot be played.',
        );
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize();
      await controller.play();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
      });
    } catch (e, st) {
      await controller.dispose();
      if (!mounted) {
        return;
      }
      AppLogger.error(
        scope: 'VideoPlayerPage.initialize',
        error: e,
        stackTrace: st,
      );
      setState(() {
        _error = AppErrorPolicy.userMessage(
          error: e,
          fallback: 'Video initialization failed. Please try again.',
        );
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _seekTo(double milliseconds) async {
    final controller = _controller;
    if (controller == null) {
      return;
    }
    await controller.seekTo(Duration(milliseconds: milliseconds.toInt()));
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _error != null
            ? Center(child: Text(_error!))
            : controller == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio == 0
                        ? 16 / 9
                        : controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: controller,
                    builder: (context, value, _) {
                      final total = value.duration.inMilliseconds.toDouble();
                      final position = value.position.inMilliseconds
                          .toDouble()
                          .clamp(0.0, total <= 0 ? 0.0 : total);
                      return Column(
                        children: [
                          Slider(
                            value: total <= 0 ? 0.0 : position,
                            max: total <= 0 ? 1 : total,
                            onChanged: total <= 0 ? null : _seekTo,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(value.position)),
                              Text(_formatDuration(value.duration)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _togglePlay,
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    label: Text(controller.value.isPlaying ? 'Pause' : 'Play'),
                  ),
                ],
              ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}
