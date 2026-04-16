import 'package:yealico/core/errors/runtime_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_engine.dart';

void main() {
  final engine = RuleRuntimeEngine();

  test('parses index list and normalizes detail URLs', () {
    final rule = _comicRule();
    const html = '''
<html><body>
  <div class="item"><a href="/detail/1"><span class="title">  One  </span></a></div>
  <div class="item"><a href="/detail/2"><span class="title">Two</span></a></div>
</body></html>
''';
    final result = engine.parseIndex(
      ruleJson: rule,
      html: html,
      pageUri: Uri.parse('https://example.com/list'),
    );

    expect(result.length, 2);
    expect(result.first.title, 'One');
    expect(result.first.detailUrl, 'https://example.com/detail/1');
  });

  test('parses detail list', () {
    final rule = _comicRule();
    const html = '''
<html><body>
  <div class="chapter"><a href="/read/1"><span class="c-title">Chapter 1</span></a></div>
  <div class="chapter"><a href="/read/2"><span class="c-title">Chapter 2</span></a></div>
</body></html>
''';
    final result = engine.parseDetail(
      ruleJson: rule,
      html: html,
      pageUri: Uri.parse('https://example.com/detail/1'),
    );

    expect(result.length, 2);
    expect(result[1].url, 'https://example.com/read/2');
  });

  test('parses comic content image URLs', () {
    final rule = _comicRule();
    const html = '''
<html><body>
  <div class="reader"><img data-src="/img/1.jpg?token=abc"></div>
  <div class="reader"><img data-src="/img/2.jpg?token=def"></div>
</body></html>
''';
    final payload = engine.parseContent(
      ruleJson: rule,
      html: html,
      pageUri: Uri.parse('https://example.com/read/1'),
    );

    expect(payload.contentType, ContentType.comic);
    expect(payload.imageUrls, [
      'https://example.com/img/1.jpg',
      'https://example.com/img/2.jpg',
    ]);
    expect(
        payload.resources.map((resource) => resource.url), payload.imageUrls);
    expect(payload.resources.every((resource) => resource.headers.isEmpty),
        isTrue);
  });

  test('parses video content URL', () {
    final rule = _videoRule();
    const html = '''
<html><body>
  <video><source src="/media/v1.mp4"></video>
</body></html>
''';
    final payload = engine.parseContent(
      ruleJson: rule,
      html: html,
      pageUri: Uri.parse('https://example.com/ep/1'),
    );

    expect(payload.contentType, ContentType.video);
    expect(payload.video?.url, 'https://example.com/media/v1.mp4');
    expect(payload.videoUrl, 'https://example.com/media/v1.mp4');
  });

  test('decryptScript results override html selector parsing for image payload',
      () {
    final rule = _comicRule();
    const html = '<html><body><div class="reader"></div></body></html>';
    final payload = engine.parseContent(
      ruleJson: rule,
      html: html,
      pageUri: Uri.parse('https://example.com/read/1'),
      decryptResult: '["/from/decrypt/1.jpg","https://cdn.example.com/2.jpg"]',
      requestHeaders: const <String, String>{
        'Referer': 'https://example.com',
        'Cookie': 'cf_clearance=abc',
      },
    );

    expect(payload.contentType, ContentType.comic);
    expect(payload.imageUrls, [
      'https://example.com/from/decrypt/1.jpg',
      'https://cdn.example.com/2.jpg',
    ]);
    expect(payload.resources.first.headers['Referer'], 'https://example.com');
    expect(payload.resources.first.headers['Cookie'], 'cf_clearance=abc');
  });

  test('throws decrypt script exception when decrypt result is invalid json',
      () {
    final rule = _comicRule();
    expect(
      () => engine.parseContent(
        ruleJson: rule,
        html: '<html></html>',
        pageUri: Uri.parse('https://example.com/read/1'),
        decryptResult: 'not-json',
      ),
      throwsA(isA<DecryptScriptExecutionException>()),
    );
  });
}

Map<String, dynamic> _comicRule() {
  return <String, dynamic>{
    'version': '1.0',
    'meta': <String, dynamic>{
      'siteId': 'comic',
      'siteName': 'Comic',
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
        'title': <String, dynamic>{
          'selector': '.title',
          'function': 'text',
          'trim': true,
        },
        'detailUrl': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
          'absoluteUrl': true,
        },
      },
    },
    'detailRule': <String, dynamic>{
      'item': <String, dynamic>{'selector': '.chapter'},
      'fields': <String, dynamic>{
        'title': <String, dynamic>{
          'selector': '.c-title',
          'function': 'text',
          'trim': true,
        },
        'url': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
          'absoluteUrl': true,
        },
      },
    },
    'contentRule': <String, dynamic>{
      'images': <String, dynamic>{
        'item': <String, dynamic>{'selector': '.reader'},
        'fields': <String, dynamic>{
          'url': <String, dynamic>{
            'selector': 'img',
            'function': 'attr',
            'param': 'data-src',
            'regex': r'\?token=.*$',
            'replacement': '',
            'absoluteUrl': true,
          },
        },
      },
    },
  };
}

Map<String, dynamic> _videoRule() {
  final rule = _comicRule();
  rule['meta'] = <String, dynamic>{
    'siteId': 'video',
    'siteName': 'Video',
    'baseUrl': 'https://example.com',
    'contentType': 'video',
  };
  rule['contentRule'] = <String, dynamic>{
    'video': <String, dynamic>{
      'url': <String, dynamic>{
        'selector': 'video source',
        'function': 'attr',
        'param': 'src',
        'absoluteUrl': true,
      },
    },
  };
  return rule;
}
