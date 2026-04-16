import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_payload.dart';
import 'package:yealico/core/models/content_resource.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/content/domain/video_content_loader.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test('runtime video loader returns parsed video resource', () async {
    final loader = RuntimeVideoContentLoader(
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
        rawJson:
            '{"version":"1.0","meta":{},"request":{},"routes":{},"indexRule":{},"detailRule":{},"contentRule":{}}',
        importedAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final resource = await loader.loadVideoResource(
      site: site,
      contentUrl: 'https://example.com/ep/1',
    );
    expect(resource.url, 'https://cdn.example.com/v1.m3u8');
    expect(resource.headers['Referer'], 'https://example.com');

    final videoUrl = await loader.loadVideoUrl(
      site: site,
      contentUrl: 'https://example.com/ep/1',
    );
    expect(videoUrl, 'https://cdn.example.com/v1.m3u8');
  });

  test('runtime video loader rejects non-video site', () async {
    final loader = RuntimeVideoContentLoader(
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
        rawJson: '{}',
        importedAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    await expectLater(
      () => loader.loadVideoUrl(
        site: site,
        contentUrl: 'https://example.com/read/1',
      ),
      throwsA(isA<VideoContentLoadException>()),
    );
  });
}

class _FakeRuntimeService extends RuleRuntimeService {
  @override
  Future<ContentPayload> loadContent({
    required Map<String, dynamic> ruleJson,
    required String contentUrl,
  }) async {
    return const ContentPayload.video(
      video: ContentResource(
        url: 'https://cdn.example.com/v1.m3u8',
        headers: <String, String>{'Referer': 'https://example.com'},
      ),
    );
  }
}
