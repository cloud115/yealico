import 'package:html/dom.dart';

class ExtractorEngine {
  const ExtractorEngine();

  String? extract({
    required Element scope,
    required Map<String, dynamic> extractor,
    Uri? baseUri,
  }) {
    final selector = (extractor['selector'] as String?) ?? '';
    final fn = extractor['function'] as String?;
    if (fn == null) {
      return null;
    }

    Element? target;
    if (selector.isEmpty) {
      target = scope;
    } else {
      target = scope.querySelector(selector);
    }

    if (target == null) {
      return null;
    }

    var value = switch (fn) {
      'text' => target.text,
      'html' => target.innerHtml,
      'attr' => _extractAttr(target, extractor),
      _ => null,
    };

    if (value == null) {
      return null;
    }

    final regex = extractor['regex'] as String?;
    final replacement = extractor['replacement'] as String?;
    if (regex != null && regex.isNotEmpty) {
      value = value.replaceAll(RegExp(regex), replacement ?? '');
    }

    if (extractor['trim'] == true) {
      value = value.trim();
    }

    if (extractor['absoluteUrl'] == true && baseUri != null) {
      final parsed = Uri.tryParse(value);
      if (parsed != null) {
        value = parsed.isAbsolute
            ? parsed.toString()
            : baseUri.resolveUri(parsed).toString();
      }
    }

    return value;
  }

  String? _extractAttr(Element target, Map<String, dynamic> extractor) {
    final param = extractor['param'] as String?;
    if (param == null || param.isEmpty) {
      return null;
    }
    return target.attributes[param];
  }
}
