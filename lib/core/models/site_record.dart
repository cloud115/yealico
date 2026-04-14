import 'content_type.dart';
import 'rule_snapshot.dart';

class SiteRecord {
  const SiteRecord({
    required this.siteId,
    required this.siteName,
    required this.baseUrl,
    required this.contentType,
    required this.rule,
    required this.createdAt,
    required this.updatedAt,
    this.isEnabled = true,
  });

  final String siteId;
  final String siteName;
  final String baseUrl;
  final ContentType contentType;
  final RuleSnapshot rule;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEnabled;

  SiteRecord copyWith({
    String? siteName,
    String? baseUrl,
    ContentType? contentType,
    RuleSnapshot? rule,
    DateTime? updatedAt,
    bool? isEnabled,
  }) {
    return SiteRecord(
      siteId: siteId,
      siteName: siteName ?? this.siteName,
      baseUrl: baseUrl ?? this.baseUrl,
      contentType: contentType ?? this.contentType,
      rule: rule ?? this.rule,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'siteId': siteId,
      'siteName': siteName,
      'baseUrl': baseUrl,
      'contentType': contentType.value,
      'rule': rule.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEnabled': isEnabled,
    };
  }

  static SiteRecord fromMap(Map<String, Object?> map) {
    return SiteRecord(
      siteId: map['siteId']! as String,
      siteName: map['siteName']! as String,
      baseUrl: map['baseUrl']! as String,
      contentType: ContentTypeCodec.parse(map['contentType']! as String),
      rule: RuleSnapshot.fromMap((map['rule']! as Map).cast<String, Object?>()),
      createdAt: DateTime.parse(map['createdAt']! as String),
      updatedAt: DateTime.parse(map['updatedAt']! as String),
      isEnabled: map['isEnabled']! as bool,
    );
  }
}
