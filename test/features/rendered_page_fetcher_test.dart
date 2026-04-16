import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/features/rule_runtime/data/rendered_page_fetcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('yealico/rendered_page');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('rendered page fetcher decodes method-channel payload', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'fetchRenderedPage');
          return <String, dynamic>{
            'finalUrl': 'https://example.com/list',
            'html': '<html><title>ok</title></html>',
            'title': 'ok',
            'cookies': 'cf_clearance=abc',
            'decryptResult': null,
            'challengeDetected': false,
          };
        });

    final result = await RenderedPageFetcher().fetch(
      uri: Uri.parse('https://example.com/list'),
      userAgent: 'ua',
      timeout: const Duration(seconds: 5),
    );

    expect(result.finalUri.toString(), 'https://example.com/list');
    expect(result.html, '<html><title>ok</title></html>');
    expect(result.cookies, contains('cf_clearance'));
  });
}
