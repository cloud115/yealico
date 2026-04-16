import '../../../core/models/catalog_entry.dart';
import '../../../core/models/content_payload.dart';
import '../../../core/models/detail_entry.dart';
import '../data/html_page_fetcher.dart';
import '../data/runtime_page_fetcher.dart';
import '../../../core/errors/runtime_exceptions.dart';
import 'rule_runtime_engine.dart';

class RuleRuntimeService {
  RuleRuntimeService({
    RuntimePageFetcher? pageFetcher,
    HtmlPageFetcher? fetcher,
    RuleRuntimeEngine? engine,
  })  : _pageFetcher =
            pageFetcher ?? RuntimePageFetcher(directFetcher: fetcher),
        _engine = engine ?? RuleRuntimeEngine();

  final RuntimePageFetcher _pageFetcher;
  final RuleRuntimeEngine _engine;

  Future<List<CatalogEntry>> loadIndex(Map<String, dynamic> ruleJson) async {
    final request = _requestConfig(ruleJson);
    final routes = (ruleJson['routes']! as Map).cast<String, dynamic>();
    final indexUrl = routes['indexUrl']! as String;
    final uri = Uri.parse(indexUrl);
    final response = await _pageFetcher.fetch(
      uri: uri,
      ruleJson: ruleJson,
      timeout: request.timeout,
    );
    _throwIfVerificationPending(response);
    return _engine.parseIndex(
      ruleJson: ruleJson,
      html: response.html,
      pageUri: response.finalUri,
    );
  }

  Future<List<DetailEntry>> loadDetail({
    required Map<String, dynamic> ruleJson,
    required String detailUrl,
  }) async {
    final request = _requestConfig(ruleJson);
    final uri = Uri.parse(detailUrl);
    final response = await _pageFetcher.fetch(
      uri: uri,
      ruleJson: ruleJson,
      timeout: request.timeout,
    );
    _throwIfVerificationPending(response);
    return _engine.parseDetail(
      ruleJson: ruleJson,
      html: response.html,
      pageUri: response.finalUri,
    );
  }

  Future<ContentPayload> loadContent({
    required Map<String, dynamic> ruleJson,
    required String contentUrl,
  }) async {
    final request = _requestConfig(ruleJson);
    final uri = Uri.parse(contentUrl);
    final response = await _pageFetcher.fetch(
      uri: uri,
      ruleJson: ruleJson,
      timeout: request.timeout,
      decryptScript: _decryptScript(ruleJson),
    );
    _throwIfVerificationPending(response);
    return _engine.parseContent(
      ruleJson: ruleJson,
      html: response.html,
      pageUri: response.finalUri,
      decryptResult: response.decryptResult,
      requestHeaders: response.requestHeaders,
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

  String? _decryptScript(Map<String, dynamic> ruleJson) {
    final contentRule =
        (ruleJson['contentRule'] as Map?)?.cast<String, dynamic>();
    final decryptScript = contentRule?['decryptScript'];
    return decryptScript is String && decryptScript.isNotEmpty
        ? decryptScript
        : null;
  }

  void _throwIfVerificationPending(RuntimePageResult response) {
    if (response.challengeDetected) {
      throw const SiteVerificationPendingException();
    }
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
