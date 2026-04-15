import 'dart:convert';

import '../../../core/models/content_type.dart';
import '../../../core/models/site_record.dart';
import '../../rule_runtime/domain/rule_runtime_service.dart';

abstract interface class ImageContentLoader {
  Future<List<String>> loadImageUrls({
    required SiteRecord site,
    required String contentUrl,
  });
}

class RuntimeImageContentLoader implements ImageContentLoader {
  RuntimeImageContentLoader({RuleRuntimeService? runtimeService})
    : _runtimeService = runtimeService ?? RuleRuntimeService();

  final RuleRuntimeService _runtimeService;

  @override
  Future<List<String>> loadImageUrls({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    if (site.contentType == ContentType.video) {
      throw const ImageContentLoadException(
        'Video sites are not supported in T10 image parsing.',
      );
    }

    final decoded = jsonDecode(site.rule.rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const ImageContentLoadException(
        'Rule JSON root must be an object.',
      );
    }

    final payload = await _runtimeService.loadContent(
      ruleJson: decoded,
      contentUrl: contentUrl,
    );
    if (payload.contentType == ContentType.video) {
      throw const ImageContentLoadException(
        'Parsed content is video, not image list.',
      );
    }
    return payload.imageUrls;
  }
}

class ImageContentLoadException implements Exception {
  const ImageContentLoadException(this.message);

  final String message;

  @override
  String toString() => 'ImageContentLoadException: $message';
}
