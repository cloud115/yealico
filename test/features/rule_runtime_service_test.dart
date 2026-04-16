import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/errors/runtime_exceptions.dart';
import 'package:yealico/features/rule_runtime/data/runtime_page_fetcher.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_engine.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test(
      'loadIndex uses rendered result when runtime fetcher returns rendered html',
      () async {
    final service = RuleRuntimeService(
      pageFetcher: _FakeRuntimePageFetcher(
        result: RuntimePageResult(
          finalUri: Uri.parse('https://example.com/list'),
          html:
              '<div class="item"><a href="/d1"><span class="title">A</span></a></div>',
          title: 'List',
          cookies: 'cf_clearance=abc',
          requestHeaders: const <String, String>{
            'User-Agent': 'ua',
            'Cookie': 'cf_clearance=abc',
          },
        ),
      ),
      engine: RuleRuntimeEngine(),
    );

    final list = await service.loadIndex(_rule());

    expect(list.length, 1);
    expect(list.first.title, 'A');
    expect(list.first.detailUrl, 'https://example.com/d1');
  });

  test(
      'loadIndex throws verification pending when rendered fetch detects challenge',
      () async {
    final service = RuleRuntimeService(
      pageFetcher: _FakeRuntimePageFetcher(
        result: RuntimePageResult(
          finalUri: Uri.parse('https://example.com/challenge'),
          html: '<html></html>',
          title: 'Cloudflare',
          cookies: '',
          requestHeaders: const <String, String>{'User-Agent': 'ua'},
          challengeDetected: true,
        ),
      ),
      engine: RuleRuntimeEngine(),
    );

    await expectLater(
      () => service.loadIndex(_rule()),
      throwsA(isA<SiteVerificationPendingException>()),
    );
  });
}

class _FakeRuntimePageFetcher extends RuntimePageFetcher {
  _FakeRuntimePageFetcher({required this.result});

  final RuntimePageResult result;

  @override
  Future<RuntimePageResult> fetch({
    required Uri uri,
    required Map<String, dynamic> ruleJson,
    required Duration timeout,
    String? decryptScript,
  }) async {
    return result;
  }
}

Map<String, dynamic> _rule() {
  return <String, dynamic>{
    'version': '1.0',
    'meta': <String, dynamic>{
      'siteId': 'demo',
      'siteName': 'Demo',
      'baseUrl': 'https://example.com',
      'contentType': 'comic',
    },
    'request': <String, dynamic>{'method': 'GET'},
    'routes': <String, dynamic>{
      'indexUrl': 'https://example.com/list',
      'detailUrlMode': 'direct',
    },
    'indexRule': <String, dynamic>{
      'item': <String, dynamic>{'selector': '.item'},
      'fields': <String, dynamic>{
        'title': <String, dynamic>{'selector': '.title', 'function': 'text'},
        'detailUrl': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
          'absoluteUrl': true,
        },
      },
    },
    'detailRule': <String, dynamic>{
      'item': <String, dynamic>{'selector': '.d'},
      'fields': <String, dynamic>{
        'title': <String, dynamic>{'selector': '.t', 'function': 'text'},
        'url': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
        },
      },
    },
    'contentRule': <String, dynamic>{
      'images': <String, dynamic>{
        'item': <String, dynamic>{'selector': '.r'},
        'fields': <String, dynamic>{
          'url': <String, dynamic>{
            'selector': 'img',
            'function': 'attr',
            'param': 'src',
          },
        },
      },
    },
  };
}
