class ContentResource {
  const ContentResource({
    required this.url,
    this.headers = const <String, String>{},
  });

  final String url;
  final Map<String, String> headers;

  Map<String, Object?> toMap() {
    return <String, Object?>{'url': url, 'headers': headers};
  }

  static ContentResource fromMap(Map<String, Object?> map) {
    final headers = <String, String>{};
    final rawHeaders = map['headers'];
    if (rawHeaders is Map) {
      for (final entry in rawHeaders.entries) {
        if (entry.key is String && entry.value is String) {
          headers[entry.key as String] = entry.value as String;
        }
      }
    }
    return ContentResource(url: map['url'] as String, headers: headers);
  }
}
