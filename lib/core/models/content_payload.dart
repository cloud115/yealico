import 'content_resource.dart';
import 'content_type.dart';

class ContentPayload {
  const ContentPayload.comicOrGallery({
    required this.contentType,
    required this.resources,
  }) : video = null;

  const ContentPayload.video({required this.video})
      : contentType = ContentType.video,
        resources = const <ContentResource>[];

  final ContentType contentType;
  final List<ContentResource> resources;
  final ContentResource? video;

  // 兼容旧调用方：继续暴露 URL 视图，后续逐步迁移到 resource 模型。
  List<String> get imageUrls =>
      resources.map((resource) => resource.url).toList(
            growable: false,
          );

  // 兼容旧调用方：继续暴露视频 URL 快捷访问。
  String? get videoUrl => video?.url;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'contentType': contentType.value,
      'resources': resources.map((resource) => resource.toMap()).toList(
            growable: false,
          ),
      'video': video?.toMap(),
      // 兼容旧字段
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
    };
  }

  static ContentPayload fromMap(Map<String, Object?> map) {
    final type = ContentTypeCodec.parse(map['contentType']! as String);
    if (type == ContentType.video) {
      final rawVideo = map['video'];
      if (rawVideo is Map<String, Object?>) {
        return ContentPayload.video(video: ContentResource.fromMap(rawVideo));
      }

      final legacyVideoUrl = map['videoUrl'] as String?;
      if (legacyVideoUrl == null || legacyVideoUrl.isEmpty) {
        throw ArgumentError('Video payload must contain video or videoUrl.');
      }
      return ContentPayload.video(video: ContentResource(url: legacyVideoUrl));
    }

    final rawResources = map['resources'];
    if (rawResources is List) {
      final resources = rawResources
          .whereType<Map>()
          .map(
            (entry) => ContentResource.fromMap(
              entry.cast<String, Object?>(),
            ),
          )
          .toList(growable: false);
      return ContentPayload.comicOrGallery(
          contentType: type, resources: resources);
    }

    final legacyUrls =
        (map['imageUrls'] as List?)?.cast<String>() ?? const <String>[];
    final resources = legacyUrls
        .map((url) => ContentResource(url: url))
        .toList(growable: false);
    return ContentPayload.comicOrGallery(
        contentType: type, resources: resources);
  }
}
