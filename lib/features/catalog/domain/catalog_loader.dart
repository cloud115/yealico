import 'dart:convert';
import 'dart:async';

import '../../../core/errors/runtime_exceptions.dart';
import '../../../core/models/catalog_entry.dart';
import '../../../core/models/site_record.dart';
import '../../rule_runtime/data/html_page_fetcher.dart';
import '../../rule_runtime/domain/rule_runtime_service.dart';

abstract interface class CatalogLoader {
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site);
}

class RuntimeCatalogLoader implements CatalogLoader {
  RuntimeCatalogLoader({RuleRuntimeService? runtimeService})
      : _runtimeService = runtimeService ?? RuleRuntimeService();

  final RuleRuntimeService _runtimeService;
  final Map<String, int> _nonNetworkFailures = <String, int>{};

  @override
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site) async {
    final decoded = jsonDecode(site.rule.rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const CatalogLoadException('Rule JSON root must be an object.');
    }
    try {
      final items = await _runtimeService.loadIndex(decoded);
      _nonNetworkFailures.remove(site.siteId);
      return items;
    } catch (error) {
      if (_isNetworkFailure(error)) {
        rethrow;
      }
      final count = (_nonNetworkFailures[site.siteId] ?? 0) + 1;
      _nonNetworkFailures[site.siteId] = count;
      if (count >= 2) {
        throw const SiteRateLimitedException();
      }
      rethrow;
    }
  }

  bool _isNetworkFailure(Object error) {
    return error is TimeoutException ||
        (error is HtmlFetchException && error.isNetworkFailure);
  }
}

class CatalogLoadException implements Exception {
  const CatalogLoadException(this.message);

  final String message;

  @override
  String toString() => 'CatalogLoadException: $message';
}
