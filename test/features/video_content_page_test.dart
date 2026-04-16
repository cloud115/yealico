import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_resource.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/content/domain/video_content_loader.dart';
import 'package:yealico/features/content/presentation/video_content_page.dart';

void main() {
  testWidgets('renders parsed video url', (WidgetTester tester) async {
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
        home: VideoContentPage(
          site: site,
          contentUrl: 'https://example.com/ep/1',
          title: 'Episode 1',
          loader: const _FakeVideoLoader(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Episode 1 Video URL'), findsOneWidget);
    expect(find.text('Parsed video URL'), findsOneWidget);
    expect(find.text('https://cdn.example.com/v1.m3u8'), findsOneWidget);
    expect(find.text('Play Video (T13)'), findsOneWidget);
  });
}

class _FakeVideoLoader implements VideoContentLoader {
  const _FakeVideoLoader();

  @override
  Future<ContentResource> loadVideoResource({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    return const ContentResource(url: 'https://cdn.example.com/v1.m3u8');
  }

  @override
  Future<String> loadVideoUrl({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    final resource =
        await loadVideoResource(site: site, contentUrl: contentUrl);
    return resource.url;
  }
}
