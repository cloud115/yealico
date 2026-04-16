import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/models/content_type.dart';
import 'package:yealico/features/rule_runtime/domain/rule_runtime_engine.dart';

void main() {
  final engine = RuleRuntimeEngine();

  test('selector parsed image resources carry runtime request headers', () {
    final payload = engine.parseContent(
      ruleJson: _comicRule(),
      html: '''
<html><body>
  <div class="reader"><img src="/img/1.jpg"></div>
  <div class="reader"><img src="/img/2.jpg"></div>
</body></html>
''',
      pageUri: Uri.parse('https://example.com/read/1'),
      requestHeaders: const <String, String>{
        'Referer': 'https://example.com',
        'Cookie': 'cf_clearance=abc',
      },
    );

    expect(payload.contentType, ContentType.comic);
    expect(payload.resources.length, 2);
    expect(payload.resources.first.headers['Referer'], 'https://example.com');
    expect(payload.resources.first.headers['Cookie'], 'cf_clearance=abc');
  });

  test('decrypt parsed video resource carries runtime request headers', () {
    final payload = engine.parseContent(
      ruleJson: _videoRule(),
      html: '<html><body></body></html>',
      pageUri: Uri.parse('https://example.com/ep/1'),
      decryptResult: '"https://cdn.example.com/v1.m3u8"',
      requestHeaders: const <String, String>{'User-Agent': 'DemoUA'},
    );

    expect(payload.contentType, ContentType.video);
    expect(payload.video?.url, 'https://cdn.example.com/v1.m3u8');
    expect(payload.video?.headers['User-Agent'], 'DemoUA');
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
        'title': <String, dynamic>{'selector': '.title', 'function': 'text'},
        'detailUrl': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
        },
      },
    },
    'detailRule': <String, dynamic>{
      'item': <String, dynamic>{'selector': '.chapter'},
      'fields': <String, dynamic>{
        'title': <String, dynamic>{'selector': '.c-title', 'function': 'text'},
        'url': <String, dynamic>{
          'selector': 'a',
          'function': 'attr',
          'param': 'href',
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
            'param': 'src',
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
