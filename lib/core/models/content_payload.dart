import 'content_type.dart';

class ContentPayload {
  const ContentPayload.comicOrGallery({
    required this.contentType,
    required this.imageUrls,
  }) : videoUrl = null;

  const ContentPayload.video({required this.videoUrl})
    : contentType = ContentType.video,
      imageUrls = const <String>[];

  final ContentType contentType;
  final List<String> imageUrls;
  final String? videoUrl;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'contentType': contentType.value,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
    };
  }

  static ContentPayload fromMap(Map<String, Object?> map) {
    final type = ContentTypeCodec.parse(map['contentType']! as String);
    if (type == ContentType.video) {
      return ContentPayload.video(videoUrl: map['videoUrl']! as String);
    }
    final urls = (map['imageUrls']! as List).cast<String>();
    return ContentPayload.comicOrGallery(contentType: type, imageUrls: urls);
  }
}
