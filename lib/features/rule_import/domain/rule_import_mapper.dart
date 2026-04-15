import '../../../core/models/content_type.dart';
import '../../../core/models/rule_import_request.dart';
import '../../../core/models/rule_snapshot.dart';
import '../../../core/models/site_record.dart';

class RuleImportMapper {
  const RuleImportMapper();

  SiteRecord toSiteRecord(RuleImportRequest request) {
    final meta = (request.parsedJson['meta']! as Map).cast<String, dynamic>();
    final siteId = (meta['siteId'] as String?)?.trim();
    final siteName = (meta['siteName'] as String?)?.trim();
    final baseUrl = (meta['baseUrl'] as String?)?.trim();
    final contentTypeRaw = (meta['contentType'] as String?)?.trim();
    final version = (request.parsedJson['version'] as String?)?.trim() ?? '1.0';

    if (siteId == null || siteId.isEmpty) {
      throw const FormatException('siteId is missing.');
    }
    if (siteName == null || siteName.isEmpty) {
      throw const FormatException('siteName is missing.');
    }
    if (baseUrl == null || baseUrl.isEmpty) {
      throw const FormatException('baseUrl is missing.');
    }
    if (contentTypeRaw == null || contentTypeRaw.isEmpty) {
      throw const FormatException('contentType is missing.');
    }

    final now = DateTime.now().toUtc();
    return SiteRecord(
      siteId: siteId,
      siteName: siteName,
      baseUrl: baseUrl,
      contentType: ContentTypeCodec.parse(contentTypeRaw),
      rule: RuleSnapshot(
        version: version,
        sourceUrl: request.sourceUrl,
        rawJson: request.rawJson,
        importedAt: request.importedAt,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }
}
