import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/content/domain/image_content_loader.dart';
import 'package:yealico/features/content/presentation/image_content_page.dart';

void main() {
  testWidgets('renders image url list from loader', (
    WidgetTester tester,
  ) async {
    final site = SiteRecord(
      siteId: 'comic-site',
      siteName: 'Comic Site',
      baseUrl: 'https://example.com',
      contentType: ContentType.comic,
      rule: RuleSnapshot(
        version: '1.0',
        sourceUrl: 'https://raw.githubusercontent.com/org/repo/main/rule.json',
        rawJson: '{}',
        importedAt: DateTime.utc(2026, 4, 15),
      ),
      createdAt: DateTime.utc(2026, 4, 15),
      updatedAt: DateTime.utc(2026, 4, 15),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ImageContentPage(
          site: site,
          contentUrl: 'https://example.com/read/1',
          title: 'Chapter 1',
          loader: const _FakeImageLoader(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chapter 1 Images'), findsOneWidget);
    expect(
      find.textContaining('https://example.com/img/1.jpg'),
      findsOneWidget,
    );
    expect(
      find.textContaining('https://example.com/img/2.jpg'),
      findsOneWidget,
    );
    expect(find.text('Open Reader (T11)'), findsOneWidget);
  });
}

class _FakeImageLoader implements ImageContentLoader {
  const _FakeImageLoader();

  @override
  Future<List<String>> loadImageUrls({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    return const <String>[
      'https://example.com/img/1.jpg',
      'https://example.com/img/2.jpg',
    ];
  }
}
