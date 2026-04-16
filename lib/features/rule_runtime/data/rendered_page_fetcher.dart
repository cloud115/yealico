import 'package:flutter/services.dart';

import '../../../core/models/rendered_page_result.dart';

class RenderedPageFetcher {
  static const MethodChannel _channel = MethodChannel('yealico/rendered_page');

  Future<RenderedPageResult> fetch({
    required Uri uri,
    required String userAgent,
    required Duration timeout,
    String? decryptScript,
  }) async {
    final map = await _channel.invokeMapMethod<String, dynamic>(
      'fetchRenderedPage',
      <String, dynamic>{
        'url': uri.toString(),
        'userAgent': userAgent,
        'timeoutMs': timeout.inMilliseconds,
        'decryptScript': decryptScript,
      },
    );
    if (map == null) {
      throw PlatformException(
        code: 'null-result',
        message: 'Rendered page bridge returned no payload.',
      );
    }

    return RenderedPageResult(
      finalUri: Uri.parse(map['finalUrl'] as String),
      html: map['html'] as String,
      title: map['title'] as String? ?? '',
      cookies: map['cookies'] as String? ?? '',
      decryptResult: map['decryptResult'] as String?,
      challengeDetected: map['challengeDetected'] as bool? ?? false,
    );
  }
}
