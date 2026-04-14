import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/models.dart';

void main() {
  test('site record round-trip map conversion', () {
    final now = DateTime.utc(2026, 4, 14, 12, 0, 0);
    final site = SiteRecord(
      siteId: 'demo-site',
      siteName: 'Demo Site',
      baseUrl: 'https://example.com',
      contentType: ContentType.comic,
      rule: RuleSnapshot(
        version: '1.0',
        sourceUrl: 'https://example.com/rule.json',
        rawJson: '{"version":"1.0"}',
        importedAt: now,
      ),
      createdAt: now,
      updatedAt: now,
    );

    final map = site.toMap();
    final decoded = SiteRecord.fromMap(map);

    expect(decoded.siteId, site.siteId);
    expect(decoded.siteName, site.siteName);
    expect(decoded.baseUrl, site.baseUrl);
    expect(decoded.contentType, site.contentType);
    expect(decoded.rule.sourceUrl, site.rule.sourceUrl);
  });

  test('content payload map conversion for video', () {
    const payload = ContentPayload.video(
      videoUrl: 'https://cdn.example.com/video.mp4',
    );
    final decoded = ContentPayload.fromMap(payload.toMap());

    expect(decoded.contentType, ContentType.video);
    expect(decoded.videoUrl, 'https://cdn.example.com/video.mp4');
    expect(decoded.imageUrls, isEmpty);
  });

  test('content type parse throws on unsupported value', () {
    expect(() => ContentTypeCodec.parse('novel'), throwsArgumentError);
  });
}
