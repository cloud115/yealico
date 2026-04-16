import 'dart:async';
import 'dart:collection';

typedef PrefetchTask = Future<void> Function();
typedef PrefetchDelay = Future<void> Function(Duration duration);

class ImagePrefetchScheduler {
  ImagePrefetchScheduler({
    this.maxConcurrent = 3,
    this.throttle = const Duration(milliseconds: 200),
    PrefetchDelay? delay,
  }) : _delay = delay ?? Future<void>.delayed;

  final int maxConcurrent;
  final Duration throttle;
  final PrefetchDelay _delay;

  final Queue<_QueuedPrefetchTask> _queue = Queue<_QueuedPrefetchTask>();
  int _running = 0;
  bool _disposed = false;

  int get runningCount => _running;
  int get queuedCount => _queue.length;

  Future<void> schedule(PrefetchTask task) {
    if (_disposed) {
      return Future<void>.value();
    }

    final completer = Completer<void>();
    _queue.add(_QueuedPrefetchTask(task: task, completer: completer));
    _drainQueue();
    return completer.future;
  }

  void dispose() {
    _disposed = true;
    _queue.clear();
  }

  void _drainQueue() {
    if (_disposed) {
      return;
    }

    while (_running < maxConcurrent && _queue.isNotEmpty) {
      final item = _queue.removeFirst();
      _running++;
      unawaited(_run(item));
    }
  }

  Future<void> _run(_QueuedPrefetchTask item) async {
    try {
      await item.task();
      if (!item.completer.isCompleted) {
        item.completer.complete();
      }
    } catch (error, stackTrace) {
      if (!item.completer.isCompleted) {
        item.completer.completeError(error, stackTrace);
      }
    } finally {
      _running--;
      if (!_disposed) {
        await _delay(throttle);
      }
      _drainQueue();
    }
  }
}

class _QueuedPrefetchTask {
  _QueuedPrefetchTask({required this.task, required this.completer});

  final PrefetchTask task;
  final Completer<void> completer;
}
