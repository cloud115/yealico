enum ContentType { comic, gallery, video }

extension ContentTypeCodec on ContentType {
  String get value => switch (this) {
    ContentType.comic => 'comic',
    ContentType.gallery => 'gallery',
    ContentType.video => 'video',
  };

  static ContentType parse(String value) => switch (value) {
    'comic' => ContentType.comic,
    'gallery' => ContentType.gallery,
    'video' => ContentType.video,
    _ => throw ArgumentError.value(value, 'value', 'Unsupported content type'),
  };
}
