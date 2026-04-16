class RequestProfile {
  const RequestProfile({
    required this.headers,
    required this.userAgent,
    required this.referer,
    required this.refererPolicy,
  });

  final Map<String, String> headers;
  final String userAgent;
  final String? referer;
  final String refererPolicy;
}

class RequestProfileResolver {
  static const defaultMobileUa =
      'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36';

  RequestProfile resolve({
    required Map<String, dynamic> ruleJson,
    required Uri pageUri,
    String? cookies,
  }) {
    final request = ((ruleJson['request'] as Map?) ?? const <String, dynamic>{})
        .cast<String, dynamic>();
    final meta = ((ruleJson['meta'] as Map?) ?? const <String, dynamic>{})
        .cast<String, dynamic>();
    final refererPolicy = (request['refererPolicy'] as String?) ?? 'origin';
    final userAgent = (request['userAgent'] as String?) ?? defaultMobileUa;
    final baseUrl = Uri.tryParse((meta['baseUrl'] as String?) ?? '');
    final referer = switch (refererPolicy) {
      'none' => null,
      'page' => pageUri.toString(),
      _ => baseUrl?.origin,
    };

    final headers = <String, String>{};
    final headersRaw = request['headers'];
    if (headersRaw is Map) {
      for (final entry in headersRaw.entries) {
        if (entry.key is String && entry.value is String) {
          headers[entry.key as String] = entry.value as String;
        }
      }
    }

    headers['User-Agent'] = userAgent;
    if (referer != null) {
      headers['Referer'] = referer;
    }
    if (cookies != null && cookies.isNotEmpty) {
      headers['Cookie'] = cookies;
    }

    return RequestProfile(
      headers: headers,
      userAgent: userAgent,
      referer: referer,
      refererPolicy: refererPolicy,
    );
  }
}
