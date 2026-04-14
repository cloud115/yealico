class DetailEntry {
  const DetailEntry({required this.title, required this.url});

  final String title;
  final String url;

  Map<String, Object?> toMap() {
    return <String, Object?>{'title': title, 'url': url};
  }

  static DetailEntry fromMap(Map<String, Object?> map) {
    return DetailEntry(
      title: map['title']! as String,
      url: map['url']! as String,
    );
  }
}
