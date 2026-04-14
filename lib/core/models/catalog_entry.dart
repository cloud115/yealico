class CatalogEntry {
  const CatalogEntry({
    required this.id,
    required this.title,
    required this.detailUrl,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String detailUrl;
  final String? coverUrl;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'title': title,
      'detailUrl': detailUrl,
      'coverUrl': coverUrl,
    };
  }

  static CatalogEntry fromMap(Map<String, Object?> map) {
    return CatalogEntry(
      id: map['id']! as String,
      title: map['title']! as String,
      detailUrl: map['detailUrl']! as String,
      coverUrl: map['coverUrl'] as String?,
    );
  }
}
