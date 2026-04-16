import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_payload.dart';
import 'package:yealico/core/models/content_resource.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/content/domain/image_content_loader.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test('runtime image loader returns image resources for comic site', () async {
    final loader = RuntimeImageContentLoader(
      runtimeService: _FakeRuntimeService(),
    );
    final now = DateTime.utc(2026, 4, 15);
    final site = SiteRecord(
      siteId: 'comic-site',
      siteName: 'Comic Site',
      baseUrl: 'https://example.com',
      contentType: ContentType.comic,
      rule: RuleSnapshot(
        version: '1.0',
        sourceUrl: 'https://raw.githubusercontent.com/org/repo/main/rule.json',
        rawJson:
            '{"version":"1.0","meta":{},"request":{},"routes":{},"indexRule":{},"detailRule":{},"contentRule":{}}',
        importedAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final resources = await loader.loadImageResources(
      site: site,
      contentUrl: 'https://example.com/read/1',
    );

    expect(resources.map((resource) => resource.url), [
      'https://example.com/img/1.jpg',
    ]);
    expect(resources.first.headers['Referer'], 'https://example.com');

    final urls = await loader.loadImageUrls(
      site: site,
      contentUrl: 'https://example.com/read/1',
    );
    expect(urls, ['https://example.com/img/1.jpg']);
  });

  test('runtime image loader rejects video site for T10', () async {
    final loader = RuntimeImageContentLoader(
      runtimeService: _FakeRuntimeService(),
    );
    final now = DateTime.utc(2026, 4, 15);
    final site = SiteRecord(
      siteId: 'video-site',
      siteName: 'Video Site',
      baseUrl: 'https://example.com',
      contentType: ContentType.video,
      rule: RuleSnapshot(
        version: '1.0',
        sourceUrl: 'https://raw.githubusercontent.com/org/repo/main/rule.json',
        rawJson: '{}',
        importedAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    await expectLater(
      () => loader.loadImageUrls(
        site: site,
        contentUrl: 'https://example.com/v/1',
      ),
      throwsA(isA<ImageContentLoadException>()),
    );
  });
}

class _FakeRuntimeService extends RuleRuntimeService {
  @override
  Future<ContentPayload> loadContent({
    required Map<String, dynamic> ruleJson,
    required String contentUrl,
  }) async {
    return const ContentPayload.comicOrGallery(
      contentType: ContentType.comic,
      resources: <ContentResource>[
        ContentResource(
          url: 'https://example.com/img/1.jpg',
          headers: <String, String>{'Referer': 'https://example.com'},
        ),
      ],
    );
  }
}
