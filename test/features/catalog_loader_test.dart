import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/catalog_entry.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/catalog/domain/catalog_loader.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test('runtime catalog loader decodes rule json and loads index', () async {
    final loader = RuntimeCatalogLoader(runtimeService: _FakeRuntimeService());
    final now = DateTime.utc(2026, 4, 15);
    final site = SiteRecord(
      siteId: 'demo',
      siteName: 'Demo',
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

    final items = await loader.loadCatalog(site);
    expect(items.length, 1);
    expect(items.first.title, 'Catalog Item');
  });
}

class _FakeRuntimeService extends RuleRuntimeService {
  @override
  Future<List<CatalogEntry>> loadIndex(Map<String, dynamic> ruleJson) async {
    return const <CatalogEntry>[
      CatalogEntry(
        id: 'item-1',
        title: 'Catalog Item',
        detailUrl: 'https://example.com/detail/1',
      ),
    ];
  }
}
