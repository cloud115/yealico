import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/player/presentation/video_player_page.dart';

void main() {
  testWidgets('shows invalid URL error when video url is malformed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: VideoPlayerPage(title: 'Video Test', videoUrl: 'not-a-valid-url'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invalid video URL.'), findsOneWidget);
  });
}
