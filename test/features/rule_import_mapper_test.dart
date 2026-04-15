import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_import_request.dart';
import 'package:yealico/features/rule_import/domain/rule_import_mapper.dart';

void main() {
  test('maps validated import request to site record', () {
    final mapper = const RuleImportMapper();
    final request = RuleImportRequest(
      sourceUrl: 'https://raw.githubusercontent.com/org/repo/main/rule.json',
      rawJson: '{"version":"1.0"}',
      parsedJson: <String, dynamic>{
        'version': '1.0',
        'meta': <String, dynamic>{
          'siteId': 'demo-site',
          'siteName': 'Demo Site',
          'baseUrl': 'https://example.com',
          'contentType': 'gallery',
        },
      },
      importedAt: DateTime.utc(2026, 4, 15),
    );

    final site = mapper.toSiteRecord(request);

    expect(site.siteId, 'demo-site');
    expect(site.siteName, 'Demo Site');
    expect(site.baseUrl, 'https://example.com');
    expect(site.contentType, ContentType.gallery);
    expect(site.rule.sourceUrl, request.sourceUrl);
  });
}
