import 'dart:convert';

import 'package:http/http.dart' as http;

class HtmlPageFetcher {
  const HtmlPageFetcher({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<HtmlFetchResponse> fetch({
    required Uri uri,
    required String method,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
    String charset = 'utf-8',
  }) async {
    if (method.toUpperCase() != 'GET') {
      throw const HtmlFetchException('Only GET is supported in MVP.');
    }

    final client = _client ?? http.Client();
    try {
      final response = await client.get(uri, headers: headers).timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HtmlFetchException(
          'Request failed with status ${response.statusCode}.',
        );
      }
      final body = _decodeBody(response.bodyBytes, charset);
      return HtmlFetchResponse(uri: uri, body: body);
    } on HtmlFetchException {
      rethrow;
    } on Exception catch (e) {
      throw HtmlFetchException('Request failed: $e');
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }

  String _decodeBody(List<int> bytes, String charset) {
    final lower = charset.toLowerCase();
    if (lower == 'utf-8' || lower == 'utf8') {
      return utf8.decode(bytes, allowMalformed: true);
    }
    return latin1.decode(bytes, allowInvalid: true);
  }
}

class HtmlFetchResponse {
  const HtmlFetchResponse({required this.uri, required this.body});

  final Uri uri;
  final String body;
}

class HtmlFetchException implements Exception {
  const HtmlFetchException(this.message);

  final String message;

  @override
  String toString() => 'HtmlFetchException: $message';
}
