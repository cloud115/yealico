import 'dart:convert';

import '../../../core/models/content_resource.dart';
import '../../../core/models/content_type.dart';
import '../../../core/models/site_record.dart';
import '../../rule_runtime/domain/rule_runtime_service.dart';

abstract interface class VideoContentLoader {
  Future<ContentResource> loadVideoResource({
    required SiteRecord site,
    required String contentUrl,
  });

  Future<String> loadVideoUrl({
    required SiteRecord site,
    required String contentUrl,
  });
}

class RuntimeVideoContentLoader implements VideoContentLoader {
  RuntimeVideoContentLoader({RuleRuntimeService? runtimeService})
      : _runtimeService = runtimeService ?? RuleRuntimeService();

  final RuleRuntimeService _runtimeService;

  @override
  Future<ContentResource> loadVideoResource({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    if (site.contentType != ContentType.video) {
      throw const VideoContentLoadException(
        'Only video sites are supported in T12 video parsing.',
      );
    }

    final decoded = jsonDecode(site.rule.rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const VideoContentLoadException(
        'Rule JSON root must be an object.',
      );
    }

    final payload = await _runtimeService.loadContent(
      ruleJson: decoded,
      contentUrl: contentUrl,
    );
    if (payload.contentType != ContentType.video || payload.video == null) {
      throw const VideoContentLoadException(
        'Parsed content does not contain video URL.',
      );
    }
    return payload.video!;
  }

  @override
  Future<String> loadVideoUrl({
    required SiteRecord site,
    required String contentUrl,
  }) async {
    final resource =
        await loadVideoResource(site: site, contentUrl: contentUrl);
    return resource.url;
  }
}

class VideoContentLoadException implements Exception {
  const VideoContentLoadException(this.message);

  final String message;

  @override
  String toString() => 'VideoContentLoadException: $message';
}
