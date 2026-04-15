import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/detail_entry.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/detail/domain/detail_loader.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test('runtime detail loader decodes rule json and loads details', () async {
    final loader = RuntimeDetailLoader(runtimeService: _FakeRuntimeService());
    final now = DateTime.utc(2026, 4, 15);
    final site = SiteRecord(
      siteId: 'demo',
      siteName: 'Demo',
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

    final items = await loader.loadDetail(
      site: site,
      detailUrl: 'https://example.com/detail/1',
    );
    expect(items.length, 1);
    expect(items.first.title, 'Detail Item');
  });
}

class _FakeRuntimeService extends RuleRuntimeService {
  @override
  Future<List<DetailEntry>> loadDetail({
    required Map<String, dynamic> ruleJson,
    required String detailUrl,
  }) async {
    return const <DetailEntry>[
      DetailEntry(title: 'Detail Item', url: 'https://example.com/content/1'),
    ];
  }
}
