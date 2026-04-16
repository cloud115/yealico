import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

import '../../../core/errors/runtime_exceptions.dart';
import '../../../core/models/catalog_entry.dart';
import '../../../core/models/content_payload.dart';
import '../../../core/models/content_resource.dart';
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
        extractor: (fields['id'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{},
        baseUri: pageUri,
      );
      final cover = _extractor.extract(
        scope: item,
        extractor: (fields['cover'] as Map?)?.cast<String, dynamic>() ??
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
    String? decryptResult,
    Map<String, String> requestHeaders = const <String, String>{},
  }) {
    final doc = html_parser.parse(html);
    final meta = (ruleJson['meta']! as Map).cast<String, dynamic>();
    final contentType = ContentTypeCodec.parse(meta['contentType']! as String);
    final contentRule =
        (ruleJson['contentRule']! as Map).cast<String, dynamic>();
    final normalizedHeaders = Map<String, String>.from(requestHeaders);

    final payloadFromDecrypt = _buildPayloadFromDecrypt(
      contentType: contentType,
      decryptResult: decryptResult,
      pageUri: pageUri,
      requestHeaders: normalizedHeaders,
    );
    if (payloadFromDecrypt != null) {
      return payloadFromDecrypt;
    }

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
      return ContentPayload.video(
        video: ContentResource(
          url: _normalizeUrl(url, pageUri),
          headers: normalizedHeaders,
        ),
      );
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
        urls.add(_normalizeUrl(url, pageUri));
      }
    }
    return ContentPayload.comicOrGallery(
      contentType: contentType,
      resources: urls
          .map((url) => ContentResource(url: url, headers: normalizedHeaders))
          .toList(growable: false),
    );
  }

  ContentPayload? _buildPayloadFromDecrypt({
    required ContentType contentType,
    required String? decryptResult,
    required Uri pageUri,
    required Map<String, String> requestHeaders,
  }) {
    if (decryptResult == null || decryptResult.trim().isEmpty) {
      return null;
    }

    final decoded = _decodeDecryptResult(decryptResult);
    if (contentType == ContentType.video) {
      final videoUrl = _readDecryptVideoUrl(decoded);
      return ContentPayload.video(
        video: ContentResource(
          url: _normalizeUrl(videoUrl, pageUri),
          headers: requestHeaders,
        ),
      );
    }

    final urls = _readDecryptImageUrls(decoded, pageUri);
    return ContentPayload.comicOrGallery(
      contentType: contentType,
      resources: urls
          .map((url) => ContentResource(url: url, headers: requestHeaders))
          .toList(growable: false),
    );
  }

  dynamic _decodeDecryptResult(String rawResult) {
    try {
      return jsonDecode(rawResult);
    } on FormatException {
      throw const DecryptScriptExecutionException();
    }
  }

  String _readDecryptVideoUrl(dynamic decoded) {
    if (decoded is String && decoded.isNotEmpty) {
      return decoded;
    }
    if (decoded is Map && decoded['url'] is String) {
      final url = decoded['url'] as String;
      if (url.isNotEmpty) {
        return url;
      }
    }
    throw const DecryptScriptExecutionException();
  }

  List<String> _readDecryptImageUrls(dynamic decoded, Uri pageUri) {
    if (decoded is! List) {
      throw const DecryptScriptExecutionException();
    }
    final results = <String>[];
    for (final item in decoded) {
      if (item is! String || item.isEmpty) {
        continue;
      }
      results.add(_normalizeUrl(item, pageUri));
    }
    return results;
  }

  String _normalizeUrl(String rawUrl, Uri pageUri) {
    final parsed = Uri.tryParse(rawUrl);
    if (parsed == null) {
      return rawUrl;
    }
    if (parsed.hasScheme) {
      return parsed.toString();
    }
    return pageUri.resolveUri(parsed).toString();
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
