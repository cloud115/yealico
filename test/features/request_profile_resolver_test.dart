import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/rule_runtime/domain/request_profile_resolver.dart';

void main() {
  test('request profile defaults to mobile chrome UA and origin referer', () {
    final profile = RequestProfileResolver().resolve(
      ruleJson: <String, dynamic>{
        'meta': <String, dynamic>{'baseUrl': 'https://example.com'},
        'request': <String, dynamic>{'method': 'GET'},
        'contentRule': <String, dynamic>{},
      },
      pageUri: Uri.parse('https://example.com/reader/1'),
      cookies: null,
    );

    expect(profile.userAgent, contains('Mobile'));
    expect(profile.referer, 'https://example.com');
  });

  test('request profile merges custom headers and page referer policy', () {
    final profile = RequestProfileResolver().resolve(
      ruleJson: <String, dynamic>{
        'meta': <String, dynamic>{'baseUrl': 'https://example.com'},
        'request': <String, dynamic>{
          'method': 'GET',
          'headers': <String, dynamic>{'X-Test': '1'},
          'userAgent': 'Custom UA',
          'refererPolicy': 'page',
        },
      },
      pageUri: Uri.parse('https://example.com/detail/2'),
      cookies: 'cf_clearance=abc',
    );

    expect(profile.headers['X-Test'], '1');
    expect(profile.headers['User-Agent'], 'Custom UA');
    expect(profile.headers['Referer'], 'https://example.com/detail/2');
    expect(profile.headers['Cookie'], 'cf_clearance=abc');
  });
}
