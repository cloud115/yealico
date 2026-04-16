import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/catalog_entry.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/core/errors/runtime_exceptions.dart';
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

  test(
      'second consecutive non-network catalog failure becomes site rate limited',
      () async {
    final loader = RuntimeCatalogLoader(
      runtimeService: _FakeFailingRuntimeService(
        error: const SiteVerificationPendingException(),
      ),
    );

    await expectLater(
      () => loader.loadCatalog(_fakeSite()),
      throwsA(isA<SiteVerificationPendingException>()),
    );
    await expectLater(
      () => loader.loadCatalog(_fakeSite()),
      throwsA(isA<SiteRateLimitedException>()),
    );
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

class _FakeFailingRuntimeService extends RuleRuntimeService {
  _FakeFailingRuntimeService({required this.error});

  final Object error;

  @override
  Future<List<CatalogEntry>> loadIndex(Map<String, dynamic> ruleJson) async {
    throw error;
  }
}

SiteRecord _fakeSite() {
  final now = DateTime.utc(2026, 4, 15);
  return SiteRecord(
    siteId: 'demo',
    siteName: 'Demo',
    baseUrl: 'https://example.com',
    contentType: ContentType.gallery,
    rule: RuleSnapshot(
      version: '1.0',
      sourceUrl: 'https://example.com/rule.json',
      rawJson: jsonEncode(<String, Object?>{
        'request': <String, Object?>{'method': 'GET'},
        'routes': <String, Object?>{
          'indexUrl': 'https://example.com/list',
        },
        'indexRule': <String, Object?>{
          'item': <String, Object?>{'selector': '.item'},
          'fields': <String, Object?>{
            'title': <String, Object?>{
              'selector': '.title',
              'function': 'text',
            },
            'detailUrl': <String, Object?>{
              'selector': 'a',
              'function': 'attr',
              'param': 'href',
            },
          },
        },
      }),
      importedAt: now,
    ),
    createdAt: now,
    updatedAt: now,
  );
}
