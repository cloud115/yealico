class RuleSnapshot {
  const RuleSnapshot({
    required this.version,
    required this.sourceUrl,
    required this.rawJson,
    required this.importedAt,
  });

  final String version;
  final String sourceUrl;
  final String rawJson;
  final DateTime importedAt;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'version': version,
      'sourceUrl': sourceUrl,
      'rawJson': rawJson,
      'importedAt': importedAt.toIso8601String(),
    };
  }

  static RuleSnapshot fromMap(Map<String, Object?> map) {
    return RuleSnapshot(
      version: map['version']! as String,
      sourceUrl: map['sourceUrl']! as String,
      rawJson: map['rawJson']! as String,
      importedAt: DateTime.parse(map['importedAt']! as String),
    );
  }
}
