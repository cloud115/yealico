import 'package:html/parser.dart' as html_parser;

import '../../../core/models/catalog_entry.dart';
import '../../../core/models/content_payload.dart';
import '../../../core/models/content_type.dart';
import '../../../core/models/detail_entry.dart';
import 'extractor_engine.dart';

class RuleRuntimeEngine {
  RuleRuntimeEngine({ExtractorEngine? extractor})
    : _extractor = extractor ?? const ExtractorEngine();

  final ExtractorEngine _extractor;

  List<CatalogEntry> parseIndex({
    required Map<String, dynamic> ruleJson,
    required String html,
    required Uri pageUri,
  }) {
    final doc = html_parser.parse(html);
    final indexRule = (ruleJson['indexRule']! as Map).cast<String, dynamic>();
    final itemSelector = _readItemSelector(indexRule);
    final fields = (indexRule['fields']! as Map).cast<String, dynamic>();

    final items = doc.querySelectorAll(itemSelector);
    final results = <CatalogEntry>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final title = _extractor.extract(
        scope: item,
        extractor: (fields['title']! as Map).cast<String, dynamic>(),
        baseUri: pageUri,
      );
      final detailUrl = _extractor.extract(
        scope: item,
        extractor: (fields['detailUrl']! as Map).cast<String, dynamic>(),
        baseUri: pageUri,
      );
      if (title == null || detailUrl == null) {
        continue;
      }

      final id = _extractor.extract(
        scope: item,
        extractor:
            (fields['id'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
        baseUri: pageUri,
      );
      final cover = _extractor.extract(
        scope: item,
        extractor:
            (fields['cover'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
        baseUri: pageUri,
      );

      results.add(
        CatalogEntry(
          id: id ?? '$i:$detailUrl',
          title: title,
          detailUrl: detailUrl,
          coverUrl: cover,
        ),
      );
    }
    return results;
  }

  List<DetailEntry> parseDetail({
    required Map<String, dynamic> ruleJson,
    required String html,
    required Uri pageUri,
  }) {
    final doc = html_parser.parse(html);
    final detailRule = (ruleJson['detailRule']! as Map).cast<String, dynamic>();
    final itemSelector = _readItemSelector(detailRule);
    final fields = (detailRule['fields']! as Map).cast<String, dynamic>();

    final items = doc.querySelectorAll(itemSelector);
    final results = <DetailEntry>[];
    for (final item in items) {
      final title = _extractor.extract(
        scope: item,
        extractor: (fields['title']! as Map).cast<String, dynamic>(),
        baseUri: pageUri,
      );
      final url = _extractor.extract(
        scope: item,
        extractor: (fields['url']! as Map).cast<String, dynamic>(),
        baseUri: pageUri,
      );
      if (title == null || url == null) {
        continue;
      }
      results.add(DetailEntry(title: title, url: url));
    }
    return results;
  }

  ContentPayload parseContent({
    required Map<String, dynamic> ruleJson,
    required String html,
    required Uri pageUri,
  }) {
    final doc = html_parser.parse(html);
    final meta = (ruleJson['meta']! as Map).cast<String, dynamic>();
    final contentType = ContentTypeCodec.parse(meta['contentType']! as String);
    final contentRule = (ruleJson['contentRule']! as Map)
        .cast<String, dynamic>();

    if (contentType == ContentType.video) {
      final video = (contentRule['video']! as Map).cast<String, dynamic>();
      final url = _extractor.extract(
        scope: doc.documentElement!,
        extractor: (video['url']! as Map).cast<String, dynamic>(),
        baseUri: pageUri,
      );
      if (url == null || url.isEmpty) {
        throw const RuleRuntimeException('Video URL not found.');
      }
      return ContentPayload.video(videoUrl: url);
    }

    final images = (contentRule['images']! as Map).cast<String, dynamic>();
    final itemSelector = _readItemSelector(images);
    final fields = (images['fields']! as Map).cast<String, dynamic>();
    final urlExtractor = (fields['url']! as Map).cast<String, dynamic>();
    final nodes = doc.querySelectorAll(itemSelector);
    final urls = <String>[];
    for (final node in nodes) {
      final url = _extractor.extract(
        scope: node,
        extractor: urlExtractor,
        baseUri: pageUri,
      );
      if (url != null && url.isNotEmpty) {
        urls.add(url);
      }
    }
    return ContentPayload.comicOrGallery(
      contentType: contentType,
      imageUrls: urls,
    );
  }

  String _readItemSelector(Map<String, dynamic> section) {
    final item = (section['item']! as Map).cast<String, dynamic>();
    final selector = item['selector'] as String?;
    if (selector == null || selector.isEmpty) {
      throw const RuleRuntimeException('item.selector must not be empty.');
    }
    return selector;
  }
}

class RuleRuntimeException implements Exception {
  const RuleRuntimeException(this.message);

  final String message;

  @override
  String toString() => 'RuleRuntimeException: $message';
}
