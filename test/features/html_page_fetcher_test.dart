import 'dart:convert';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yealico/features/rule_runtime/data/html_page_fetcher.dart';

void main() {
  test('uses cache for repeated GET with same key', () async {
    final fakeClient = _FakeHttpClient(
      statusCode: 200,
      body: '<html><body>ok</body></html>',
    );
    final fetcher = HtmlPageFetcher(
      client: fakeClient,
      cacheTtl: const Duration(minutes: 5),
    );
    final uri = Uri.parse('https://example.com/page');

    final first = await fetcher.fetch(uri: uri, method: 'GET');
    final second = await fetcher.fetch(uri: uri, method: 'GET');

    expect(first.body, contains('ok'));
    expect(second.body, contains('ok'));
    expect(fakeClient.callCount, 1);
  });

  test(
      'rethrows timeout exceptions so upper layers can distinguish network failures',
      () async {
    final fetcher = HtmlPageFetcher(client: _TimeoutHttpClient());

    await expectLater(
      () => fetcher.fetch(
        uri: Uri.parse('https://example.com/page'),
        method: 'GET',
      ),
      throwsA(isA<TimeoutException>()),
    );
  });
}

class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
  int callCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    callCount += 1;
    final bytes = utf8.encode(body);
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      statusCode,
      request: request,
      headers: const <String, String>{
        'content-type': 'text/html; charset=utf-8',
      },
    );
  }
}

class _TimeoutHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return Future<http.StreamedResponse>.error(
      TimeoutException('request timed out'),
    );
  }
}
