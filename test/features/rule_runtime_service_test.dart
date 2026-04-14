import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/rule_runtime/data/html_page_fetcher.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_engine.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_service.dart';

void main() {
  test('loads index through fetcher and engine', () async {
    final fetcher = _FakeHtmlFetcher(
      body:
          '<div class="item"><a href="/d1"><span class="title">A</span></a></div>',
      uri: Uri.parse('https://example.com/list'),
    );
    final service = RuleRuntimeService(
      fetcher: fetcher,
      engine: RuleRuntimeEngine(),
    );

    final list = await service.loadIndex(_rule());

    expect(list.length, 1);
    expect(list.first.title, 'A');
    expect(list.first.detailUrl, 'https://example.com/d1');
  });
}

class _FakeHtmlFetcher extends HtmlPageFetcher {
  const _FakeHtmlFetcher({required this.body, required this.uri});

  final String body;
  final Uri uri;

  @override
  Future<HtmlFetchResponse> fetch({
    required Uri uri,
    required String method,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
    String charset = 'utf-8',
  }) async {
    return HtmlFetchResponse(uri: this.uri, body: body);
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
