class ReadingHistoryEntry {
  const ReadingHistoryEntry({
    required this.siteId,
    required this.itemId,
    required this.itemTitle,
    required this.detailUrl,
    required this.progressIndex,
    required this.lastContentUrl,
    required this.updatedAt,
  });

  final String siteId;
  final String itemId;
  final String itemTitle;
  final String detailUrl;
  final int progressIndex;
  final String lastContentUrl;
  final DateTime updatedAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'siteId': siteId,
      'itemId': itemId,
      'itemTitle': itemTitle,
      'detailUrl': detailUrl,
      'progressIndex': progressIndex,
      'lastContentUrl': lastContentUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static ReadingHistoryEntry fromMap(Map<String, Object?> map) {
    return ReadingHistoryEntry(
      siteId: map['siteId']! as String,
      itemId: map['itemId']! as String,
      itemTitle: map['itemTitle']! as String,
      detailUrl: map['detailUrl']! as String,
      progressIndex: map['progressIndex']! as int,
      lastContentUrl: map['lastContentUrl']! as String,
      updatedAt: DateTime.parse(map['updatedAt']! as String),
    );
  }
}
