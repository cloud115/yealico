import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/reader/presentation/image_reader_page.dart';

void main() {
  testWidgets('shows current page indicator and supports tap navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ImageReaderPage(
          title: 'Reader Test',
          imageUrls: const <String>[
            'https://example.com/1.jpg',
            'https://example.com/2.jpg',
          ],
          imageBuilder: (context, imageUrl, index) => Text('image-$index'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('image-0'), findsOneWidget);

    final tapLayer = find.byKey(const Key('reader_tap_layer'));
    final size = tester.getSize(tapLayer);
    final topLeft = tester.getTopLeft(tapLayer);

    await tester.tapAt(
      Offset(topLeft.dx + size.width * 0.9, topLeft.dy + size.height * 0.5),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('image-1'), findsOneWidget);

    await tester.tapAt(
      Offset(topLeft.dx + size.width * 0.1, topLeft.dy + size.height * 0.5),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 / 2'), findsOneWidget);
  });
}
