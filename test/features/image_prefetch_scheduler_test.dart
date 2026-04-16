import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/reader/domain/image_prefetch_scheduler.dart';

void main() {
  test('scheduler enforces max concurrent tasks', () async {
    final scheduler = ImagePrefetchScheduler(
      maxConcurrent: 2,
      throttle: Duration.zero,
      delay: (_) async {},
    );
    final completers = List<Completer<void>>.generate(
      4,
      (_) => Completer<void>(),
      growable: false,
    );

    var running = 0;
    var maxRunning = 0;
    final futures = completers
        .map(
          (completer) => scheduler.schedule(() async {
            running++;
            if (running > maxRunning) {
              maxRunning = running;
            }
            await completer.future;
            running--;
          }),
        )
        .toList(growable: false);

    await Future<void>.delayed(Duration.zero);
    expect(maxRunning, 2);
    expect(scheduler.runningCount, 2);
    expect(scheduler.queuedCount, 2);

    completers[0].complete();
    completers[1].complete();
    await Future<void>.delayed(Duration.zero);
    expect(scheduler.runningCount, 2);
    expect(scheduler.queuedCount, 0);

    completers[2].complete();
    completers[3].complete();
    await Future.wait(futures);
    expect(scheduler.runningCount, 0);
  });

  test('scheduler applies throttle between task batches', () async {
    final delays = <Duration>[];
    var tick = 0;
    final scheduler = ImagePrefetchScheduler(
      maxConcurrent: 1,
      throttle: const Duration(milliseconds: 200),
      delay: (duration) async {
        delays.add(duration);
        tick++;
      },
    );

    final starts = <int>[];
    await Future.wait(<Future<void>>[
      scheduler.schedule(() async {
        starts.add(tick);
      }),
      scheduler.schedule(() async {
        starts.add(tick);
      }),
    ]);

    expect(starts, [0, 1]);
    expect(delays, [
      const Duration(milliseconds: 200),
      const Duration(milliseconds: 200),
    ]);
  });
}
