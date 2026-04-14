import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/rule_import/data/rule_raw_fetcher.dart';
import 'package:yealico/features/rule_import/domain/rule_import_service.dart';

void main() {
  test('creates import request from valid github raw url and json', () async {
    final service = RuleImportService(
      fetcher: _FakeFetcher(
        statusCode: 200,
        body: '''
{
  "version": "1.0",
  "meta": {
    "siteId": "demo",
    "siteName": "Demo Site",
    "baseUrl": "https://example.com",
    "contentType": "video"
  },
  "request": {"method": "GET"},
  "routes": {"indexUrl": "https://example.com/list", "detailUrlMode": "direct"},
  "indexRule": {
    "item": {"selector": ".item"},
    "fields": {
      "title": {"selector": ".title", "function": "text"},
      "detailUrl": {"selector": "a", "function": "attr", "param": "href"}
    }
  },
  "detailRule": {
    "item": {"selector": ".episode"},
    "fields": {
      "title": {"selector": ".title", "function": "text"},
      "url": {"selector": "a", "function": "attr", "param": "href"}
    }
  },
  "contentRule": {
    "video": {"url": {"selector": "video source", "function": "attr", "param": "src"}}
  }
}
''',
      ),
    );

    final request = await service.importFromUrl(
      'https://raw.githubusercontent.com/org/repo/main/rule.json',
    );

    expect(request.siteId, 'demo');
    expect(request.siteName, 'Demo Site');
    expect(request.sourceUrl, contains('raw.githubusercontent.com'));
  });

  test('rejects non github raw url', () async {
    final service = RuleImportService(
      fetcher: _FakeFetcher(statusCode: 200, body: '{}'),
    );

    await expectLater(
      () => service.importFromUrl('https://example.com/rule.json'),
      throwsA(isA<RuleImportException>()),
    );
  });

  test('rejects non object json root', () async {
    final service = RuleImportService(
      fetcher: _FakeFetcher(statusCode: 200, body: '[]'),
    );

    await expectLater(
      () => service.importFromUrl(
        'https://raw.githubusercontent.com/org/repo/main/rule.json',
      ),
      throwsA(isA<RuleImportException>()),
    );
  });

  test('rejects schema-invalid rule with validation exception', () async {
    final service = RuleImportService(
      fetcher: _FakeFetcher(
        statusCode: 200,
        body: '''
{
  "version": "1.0",
  "meta": {"siteId": "demo"},
  "request": {"method": "POST"},
  "routes": {"indexUrl": "not-url", "detailUrlMode": "script"},
  "indexRule": {},
  "detailRule": {},
  "contentRule": {}
}
''',
      ),
    );

    await expectLater(
      () => service.importFromUrl(
        'https://raw.githubusercontent.com/org/repo/main/rule.json',
      ),
      throwsA(isA<RuleValidationException>()),
    );
  });
}

class _FakeFetcher extends RuleRawFetcher {
  const _FakeFetcher({required this.statusCode, required this.body});

  final int statusCode;
  final String body;

  @override
  Future<RuleRawResponse> fetch(Uri uri) async {
    return RuleRawResponse(statusCode: statusCode, body: body);
  }
}
