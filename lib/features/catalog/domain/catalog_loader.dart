import 'dart:convert';

import '../../../core/models/catalog_entry.dart';
import '../../../core/models/site_record.dart';
import '../../rule_runtime/domain/rule_runtime_service.dart';

abstract interface class CatalogLoader {
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site);
}

class RuntimeCatalogLoader implements CatalogLoader {
  RuntimeCatalogLoader({RuleRuntimeService? runtimeService})
    : _runtimeService = runtimeService ?? RuleRuntimeService();

  final RuleRuntimeService _runtimeService;

  @override
  Future<List<CatalogEntry>> loadCatalog(SiteRecord site) async {
    final decoded = jsonDecode(site.rule.rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const CatalogLoadException('Rule JSON root must be an object.');
    }
    return _runtimeService.loadIndex(decoded);
  }
}

class CatalogLoadException implements Exception {
  const CatalogLoadException(this.message);

  final String message;

  @override
  String toString() => 'CatalogLoadException: $message';
}
