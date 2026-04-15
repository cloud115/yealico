import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/cache/ttl_cache.dart';

class HtmlPageFetcher {
  HtmlPageFetcher({
    http.Client? client,
    Duration cacheTtl = const Duration(minutes: 2),
  }) : _client = client,
       _cache = TtlCache<String, HtmlFetchResponse>(ttl: cacheTtl);

  final http.Client? _client;
  final TtlCache<String, HtmlFetchResponse> _cache;

  Future<HtmlFetchResponse> fetch({
    required Uri uri,
    required String method,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
    String charset = 'utf-8',
    bool useCache = true,
  }) async {
    if (method.toUpperCase() != 'GET') {
      throw const HtmlFetchException('Only GET is supported in MVP.');
    }

    final normalizedTimeout = _normalizeTimeout(timeout);
    final cacheKey = _cacheKey(uri: uri, headers: headers, charset: charset);
    if (useCache) {
      final cached = _cache.get(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final client = _client ?? http.Client();
    try {
      final response = await client
          .get(uri, headers: headers)
          .timeout(normalizedTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HtmlFetchException(
          'Request failed with status ${response.statusCode}.',
        );
      }
      final body = _decodeBody(response.bodyBytes, charset);
      final result = HtmlFetchResponse(uri: uri, body: body);
      if (useCache) {
        _cache.set(cacheKey, result);
      }
      return result;
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

  Duration _normalizeTimeout(Duration timeout) {
    const min = Duration(seconds: 3);
    const max = Duration(seconds: 30);
    if (timeout < min) {
      return min;
    }
    if (timeout > max) {
      return max;
    }
    return timeout;
  }

  String _cacheKey({
    required Uri uri,
    required Map<String, String>? headers,
    required String charset,
  }) {
    final sortedHeaders = (headers ?? <String, String>{}).entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final headerString = sortedHeaders
        .map((e) => '${e.key}:${e.value}')
        .join('|');
    return '${uri.toString()}|$charset|$headerString';
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
