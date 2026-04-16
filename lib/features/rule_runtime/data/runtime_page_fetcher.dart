import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/models/rendered_page_result.dart';
import '../domain/request_profile_resolver.dart';
import 'html_page_fetcher.dart';
import 'rendered_page_fetcher.dart';

class RuntimePageResult {
  const RuntimePageResult({
    required this.finalUri,
    required this.html,
    required this.title,
    required this.cookies,
    required this.requestHeaders,
    this.decryptResult,
    this.challengeDetected = false,
  });

  final Uri finalUri;
  final String html;
  final String title;
  final String cookies;
  final Map<String, String> requestHeaders;
  final String? decryptResult;
  final bool challengeDetected;
}

class RuntimePageFetcher {
  RuntimePageFetcher({
    HtmlPageFetcher? directFetcher,
    RenderedPageFetcher? renderedFetcher,
    RequestProfileResolver? requestProfileResolver,
  })  : _directFetcher = directFetcher ?? HtmlPageFetcher(),
        _renderedFetcher = renderedFetcher ?? RenderedPageFetcher(),
        _requestProfileResolver =
            requestProfileResolver ?? RequestProfileResolver();

  final HtmlPageFetcher _directFetcher;
  final RenderedPageFetcher _renderedFetcher;
  final RequestProfileResolver _requestProfileResolver;

  Future<RuntimePageResult> fetch({
    required Uri uri,
    required Map<String, dynamic> ruleJson,
    required Duration timeout,
    String? decryptScript,
  }) async {
    final request = ((ruleJson['request'] as Map?) ?? const <String, dynamic>{})
        .cast<String, dynamic>();
    final initialProfile = _requestProfileResolver.resolve(
      ruleJson: ruleJson,
      pageUri: uri,
      cookies: null,
    );
    final method = (request['method'] as String?) ?? 'GET';
    final charset = (request['charset'] as String?) ?? 'utf-8';

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final rendered = await _renderedFetcher.fetch(
          uri: uri,
          userAgent: initialProfile.userAgent,
          timeout: timeout,
          decryptScript: decryptScript,
        );
        return _fromRendered(ruleJson: ruleJson, result: rendered);
      } on MissingPluginException {
        // 测试环境或未注册平台桥接时回退到直接请求，避免阻断非 Android 场景。
      }
    }

    final direct = await _directFetcher.fetch(
      uri: uri,
      method: method,
      headers: initialProfile.headers,
      timeout: timeout,
      charset: charset,
    );
    return RuntimePageResult(
      finalUri: direct.uri,
      html: direct.body,
      title: '',
      cookies: initialProfile.headers['Cookie'] ?? '',
      requestHeaders: initialProfile.headers,
    );
  }

  RuntimePageResult _fromRendered({
    required Map<String, dynamic> ruleJson,
    required RenderedPageResult result,
  }) {
    final resourceProfile = _requestProfileResolver.resolve(
      ruleJson: ruleJson,
      pageUri: result.finalUri,
      cookies: result.cookies,
    );
    return RuntimePageResult(
      finalUri: result.finalUri,
      html: result.html,
      title: result.title,
      cookies: result.cookies,
      requestHeaders: resourceProfile.headers,
      decryptResult: result.decryptResult,
      challengeDetected: result.challengeDetected,
    );
  }
}
