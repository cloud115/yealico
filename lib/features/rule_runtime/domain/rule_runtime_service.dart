import '../../../core/models/catalog_entry.dart';
import '../../../core/models/content_payload.dart';
import '../../../core/models/detail_entry.dart';
import '../data/html_page_fetcher.dart';
import 'rule_runtime_engine.dart';

class RuleRuntimeService {
  RuleRuntimeService({HtmlPageFetcher? fetcher, RuleRuntimeEngine? engine})
    : _fetcher = fetcher ?? HtmlPageFetcher(),
      _engine = engine ?? RuleRuntimeEngine();

  final HtmlPageFetcher _fetcher;
  final RuleRuntimeEngine _engine;

  Future<List<CatalogEntry>> loadIndex(Map<String, dynamic> ruleJson) async {
    final request = _requestConfig(ruleJson);
    final routes = (ruleJson['routes']! as Map).cast<String, dynamic>();
    final indexUrl = routes['indexUrl']! as String;
    final uri = Uri.parse(indexUrl);
    final response = await _fetcher.fetch(
      uri: uri,
      method: request.method,
      headers: request.headers,
      timeout: request.timeout,
      charset: request.charset,
    );
    return _engine.parseIndex(
      ruleJson: ruleJson,
      html: response.body,
      pageUri: response.uri,
    );
  }

  Future<List<DetailEntry>> loadDetail({
    required Map<String, dynamic> ruleJson,
    required String detailUrl,
  }) async {
    final request = _requestConfig(ruleJson);
    final uri = Uri.parse(detailUrl);
    final response = await _fetcher.fetch(
      uri: uri,
      method: request.method,
      headers: request.headers,
      timeout: request.timeout,
      charset: request.charset,
    );
    return _engine.parseDetail(
      ruleJson: ruleJson,
      html: response.body,
      pageUri: response.uri,
    );
  }

  Future<ContentPayload> loadContent({
    required Map<String, dynamic> ruleJson,
    required String contentUrl,
  }) async {
    final request = _requestConfig(ruleJson);
    final uri = Uri.parse(contentUrl);
    final response = await _fetcher.fetch(
      uri: uri,
      method: request.method,
      headers: request.headers,
      timeout: request.timeout,
      charset: request.charset,
    );
    return _engine.parseContent(
      ruleJson: ruleJson,
      html: response.body,
      pageUri: response.uri,
    );
  }

  _RequestConfig _requestConfig(Map<String, dynamic> ruleJson) {
    final request = (ruleJson['request']! as Map).cast<String, dynamic>();
    final method = (request['method'] as String?) ?? 'GET';
    final charset = (request['charset'] as String?) ?? 'utf-8';
    final timeoutMs = (request['timeoutMs'] as int?) ?? 10000;
    final headersRaw = request['headers'];
    final headers = <String, String>{};
    if (headersRaw is Map) {
      for (final entry in headersRaw.entries) {
        if (entry.key is String && entry.value is String) {
          headers[entry.key as String] = entry.value as String;
        }
      }
    }
    return _RequestConfig(
      method: method,
      charset: charset,
      timeout: Duration(milliseconds: timeoutMs),
      headers: headers,
    );
  }
}

class _RequestConfig {
  const _RequestConfig({
    required this.method,
    required this.charset,
    required this.timeout,
    required this.headers,
  });

  final String method;
  final String charset;
  final Duration timeout;
  final Map<String, String> headers;
}
