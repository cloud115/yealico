import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/rule_import/domain/rule_validator.dart';

void main() {
  final validator = RuleValidator();

  test('passes for minimal valid video rule', () {
    final rule = <String, dynamic>{
      'version': '1.0',
      'meta': <String, dynamic>{
        'siteId': 'demo',
        'siteName': 'Demo',
        'baseUrl': 'https://example.com',
        'contentType': 'video',
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
        'item': <String, dynamic>{'selector': '.episode'},
        'fields': <String, dynamic>{
          'title': <String, dynamic>{'selector': '.title', 'function': 'text'},
          'url': <String, dynamic>{
            'selector': 'a',
            'function': 'attr',
            'param': 'href',
          },
        },
      },
      'contentRule': <String, dynamic>{
        'video': <String, dynamic>{
          'url': <String, dynamic>{
            'selector': 'video source',
            'function': 'attr',
            'param': 'src',
          },
        },
      },
    };

    final result = validator.validate(rule);
    expect(result.isValid, isTrue);
    expect(result.issues, isEmpty);
  });

  test('fails when method/detailUrlMode/attr-param violate MVP', () {
    final rule = <String, dynamic>{
      'version': '1.0',
      'meta': <String, dynamic>{
        'siteId': 'demo',
        'siteName': 'Demo',
        'baseUrl': 'https://example.com',
        'contentType': 'video',
      },
      'request': <String, dynamic>{'method': 'POST'},
      'routes': <String, dynamic>{
        'indexUrl': 'https://example.com/list',
        'detailUrlMode': 'script',
      },
      'indexRule': <String, dynamic>{
        'item': <String, dynamic>{'selector': '.item'},
        'fields': <String, dynamic>{
          'title': <String, dynamic>{'selector': '.title', 'function': 'text'},
          'detailUrl': <String, dynamic>{'selector': 'a', 'function': 'attr'},
        },
      },
      'detailRule': <String, dynamic>{
        'item': <String, dynamic>{'selector': '.episode'},
        'fields': <String, dynamic>{
          'title': <String, dynamic>{'selector': '.title', 'function': 'text'},
          'url': <String, dynamic>{'selector': 'a', 'function': 'attr'},
        },
      },
      'contentRule': <String, dynamic>{
        'video': <String, dynamic>{
          'url': <String, dynamic>{
            'selector': 'video source',
            'function': 'attr',
          },
        },
      },
    };

    final result = validator.validate(rule);
    final codes = result.issues.map((e) => e.code).toSet();

    expect(result.isValid, isFalse);
    expect(codes, contains('unsupported_value'));
    expect(codes, contains('missing_attr_param'));
  });
}
