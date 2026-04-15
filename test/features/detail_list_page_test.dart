import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/detail_entry.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/detail/domain/detail_loader.dart';
import 'package:yealico/features/detail/presentation/detail_list_page.dart';

void main() {
  testWidgets('renders detail items from loader', (WidgetTester tester) async {
    final site = SiteRecord(
      siteId: 'demo',
      siteName: 'Demo Site',
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
        home: DetailListPage(
          site: site,
          detailUrl: 'https://example.com/detail/1',
          catalogTitle: 'Episode 1',
          loader: const _FakeDetailLoader(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Episode 1 Details'), findsOneWidget);
    expect(find.text('Chapter A'), findsOneWidget);
    expect(find.textContaining('url:'), findsOneWidget);
    expect(find.text('Parse Images (T10)'), findsOneWidget);
  });

  testWidgets('renders T12 video action for video site', (
    WidgetTester tester,
  ) async {
    final site = SiteRecord(
      siteId: 'video-site',
      siteName: 'Video Site',
      baseUrl: 'https://example.com',
      contentType: ContentType.video,
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
        home: DetailListPage(
          site: site,
          detailUrl: 'https://example.com/detail/1',
          catalogTitle: 'Episode 1',
          loader: const _FakeDetailLoader(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Parse Video URL (T12)'), findsOneWidget);
  });
}

class _FakeDetailLoader implements DetailLoader {
  const _FakeDetailLoader();

  @override
  Future<List<DetailEntry>> loadDetail({
    required SiteRecord site,
    required String detailUrl,
  }) async {
    return const <DetailEntry>[
      DetailEntry(title: 'Chapter A', url: 'https://example.com/read/1'),
    ];
  }
}
