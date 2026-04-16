import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/catalog_entry.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/core/models/rule_snapshot.dart';
import 'package:yealico/core/models/site_record.dart';
import 'package:yealico/features/catalog/domain/catalog_loader.dart';
import 'package:yealico/features/catalog/presentation/site_catalog_page.dart';
import 'package:yealico/features/site_session/presentation/site_verification_page.dart';

void main() {
  testWidgets('renders catalog items from loader', (WidgetTester tester) async {
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
        home: SiteCatalogPage(site: site, loader: const _FakeCatalogLoader()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Demo Site Catalog'), findsOneWidget);
    expect(find.text('Episode 1'), findsOneWidget);
    expect(find.textContaining('detailUrl:'), findsOneWidget);
    expect(find.text('Open Details (T09)'), findsOneWidget);
    expect(find.byTooltip('Verify Session'), findsOneWidget);
  });

  testWidgets('verify session action opens page and refreshes catalog', (
    WidgetTester tester,
  ) async {
    final site = _demoSite();
    final loader = _CountingCatalogLoader();

    await tester.pumpWidget(
      MaterialApp(
        home: SiteCatalogPage(
          site: site,
          loader: loader,
          verificationPageBuilder: (context, site) => SiteVerificationPage(
            siteName: site.siteName,
            url: site.baseUrl,
            webViewBuilder: (context, url) => Text('mock-webview:$url'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(loader.callCount, 1);

    await tester.tap(find.byTooltip('Verify Session'));
    await tester.pumpAndSettle();
    expect(find.byType(SiteVerificationPage), findsOneWidget);

    await tester.tap(find.text('Done and Refresh'));
    await tester.pumpAndSettle();
    expect(loader.callCount, 2);
  });
}

class _FakeCatalogLoader implements CatalogLoader {
  const _FakeCatalogLoader();

  @override
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site) async {
    return const <CatalogEntry>[
      CatalogEntry(
        id: 'ep-1',
        title: 'Episode 1',
        detailUrl: 'https://example.com/ep/1',
      ),
    ];
  }
}

class _CountingCatalogLoader implements CatalogLoader {
  int callCount = 0;

  @override
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site) async {
    callCount++;
    return const <CatalogEntry>[
      CatalogEntry(
        id: 'ep-1',
        title: 'Episode 1',
        detailUrl: 'https://example.com/ep/1',
      ),
    ];
  }
}

SiteRecord _demoSite() {
  return SiteRecord(
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
}
