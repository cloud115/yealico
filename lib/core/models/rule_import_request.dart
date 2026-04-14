class RuleImportRequest {
  const RuleImportRequest({
    required this.sourceUrl,
    required this.rawJson,
    required this.parsedJson,
    required this.importedAt,
  });

  final String sourceUrl;
  final String rawJson;
  final Map<String, dynamic> parsedJson;
  final DateTime importedAt;

  String? get siteId => parsedJson['meta'] is Map<String, dynamic>
      ? (parsedJson['meta'] as Map<String, dynamic>)['siteId'] as String?
      : null;

  String? get siteName => parsedJson['meta'] is Map<String, dynamic>
      ? (parsedJson['meta'] as Map<String, dynamic>)['siteName'] as String?
      : null;
}
