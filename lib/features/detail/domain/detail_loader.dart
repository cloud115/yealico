import 'dart:convert';

import '../../../core/models/detail_entry.dart';
import '../../../core/models/site_record.dart';
import '../../rule_runtime/domain/rule_runtime_service.dart';

abstract interface class DetailLoader {
  Future<List<DetailEntry>> loadDetail({
    required SiteRecord site,
    required String detailUrl,
  });
}

class RuntimeDetailLoader implements DetailLoader {
  RuntimeDetailLoader({RuleRuntimeService? runtimeService})
    : _runtimeService = runtimeService ?? RuleRuntimeService();

  final RuleRuntimeService _runtimeService;

  @override
  Future<List<DetailEntry>> loadDetail({
    required SiteRecord site,
    required String detailUrl,
  }) async {
    final decoded = jsonDecode(site.rule.rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const DetailLoadException('Rule JSON root must be an object.');
    }
    return _runtimeService.loadDetail(ruleJson: decoded, detailUrl: detailUrl);
  }
}

class DetailLoadException implements Exception {
  const DetailLoadException(this.message);

  final String message;

  @override
  String toString() => 'DetailLoadException: $message';
}
