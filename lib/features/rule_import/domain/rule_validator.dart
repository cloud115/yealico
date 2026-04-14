class RuleValidator {
  RuleValidationResult validate(Map<String, dynamic> rule) {
    final issues = <RuleValidationIssue>[];

    _requireObject(rule, '', issues);
    _requireString(rule, 'version', issues, expectedValue: '1.0');

    final meta = _requireMap(rule, 'meta', issues);
    final request = _requireMap(rule, 'request', issues);
    final routes = _requireMap(rule, 'routes', issues);
    final indexRule = _requireMap(rule, 'indexRule', issues);
    final detailRule = _requireMap(rule, 'detailRule', issues);
    final contentRule = _requireMap(rule, 'contentRule', issues);

    String? contentType;

    if (meta != null) {
      _requireString(meta, 'siteId', issues, pathPrefix: 'meta');
      _requireString(meta, 'siteName', issues, pathPrefix: 'meta');
      final baseUrl = _requireString(
        meta,
        'baseUrl',
        issues,
        pathPrefix: 'meta',
      );
      if (baseUrl != null && !_isAbsoluteUrl(baseUrl)) {
        issues.add(
          const RuleValidationIssue(
            code: 'invalid_url',
            path: 'meta.baseUrl',
            message: 'baseUrl must be an absolute URL.',
          ),
        );
      }

      contentType = _requireString(
        meta,
        'contentType',
        issues,
        pathPrefix: 'meta',
      );
      if (contentType != null &&
          !_supportedContentTypes.contains(contentType)) {
        issues.add(
          const RuleValidationIssue(
            code: 'unsupported_content_type',
            path: 'meta.contentType',
            message: 'contentType must be one of comic/gallery/video.',
          ),
        );
      }
    }

    if (request != null) {
      _requireString(
        request,
        'method',
        issues,
        pathPrefix: 'request',
        expectedValue: 'GET',
      );
      final timeout = request['timeoutMs'];
      if (timeout != null && (timeout is! int || timeout <= 0)) {
        issues.add(
          const RuleValidationIssue(
            code: 'invalid_timeout',
            path: 'request.timeoutMs',
            message: 'timeoutMs must be a positive integer.',
          ),
        );
      }
      final headers = request['headers'];
      if (headers != null) {
        if (headers is! Map) {
          issues.add(
            const RuleValidationIssue(
              code: 'invalid_type',
              path: 'request.headers',
              message: 'headers must be an object of string key/value pairs.',
            ),
          );
        } else {
          for (final entry in headers.entries) {
            if (entry.key is! String || entry.value is! String) {
              issues.add(
                RuleValidationIssue(
                  code: 'invalid_header_entry',
                  path: 'request.headers',
                  message: 'Invalid header entry: ${entry.key}',
                ),
              );
            }
          }
        }
      }
    }

    if (routes != null) {
      final indexUrl = _requireString(
        routes,
        'indexUrl',
        issues,
        pathPrefix: 'routes',
      );
      if (indexUrl != null && !_isAbsoluteUrl(indexUrl)) {
        issues.add(
          const RuleValidationIssue(
            code: 'invalid_url',
            path: 'routes.indexUrl',
            message: 'indexUrl must be an absolute URL.',
          ),
        );
      }
      _requireString(
        routes,
        'detailUrlMode',
        issues,
        pathPrefix: 'routes',
        expectedValue: 'direct',
      );
    }

    if (indexRule != null) {
      _validateItemSelector(indexRule, 'indexRule', issues);
      final fields = _requireMap(
        indexRule,
        'fields',
        issues,
        pathPrefix: 'indexRule',
      );
      if (fields != null) {
        _validateExtractorField(
          fields,
          'title',
          'indexRule.fields.title',
          issues,
        );
        _validateExtractorField(
          fields,
          'detailUrl',
          'indexRule.fields.detailUrl',
          issues,
        );
        _validateOptionalExtractorField(
          fields,
          'id',
          'indexRule.fields.id',
          issues,
        );
        _validateOptionalExtractorField(
          fields,
          'cover',
          'indexRule.fields.cover',
          issues,
        );
      }
    }

    if (detailRule != null) {
      _validateItemSelector(detailRule, 'detailRule', issues);
      final fields = _requireMap(
        detailRule,
        'fields',
        issues,
        pathPrefix: 'detailRule',
      );
      if (fields != null) {
        _validateExtractorField(
          fields,
          'title',
          'detailRule.fields.title',
          issues,
        );
        _validateExtractorField(fields, 'url', 'detailRule.fields.url', issues);
      }
      _validateOptionalExtractorField(
        detailRule,
        'title',
        'detailRule.title',
        issues,
      );
    }

    if (contentRule != null && contentType != null) {
      if (contentType == 'comic' || contentType == 'gallery') {
        final images = _requireMap(
          contentRule,
          'images',
          issues,
          pathPrefix: 'contentRule',
        );
        if (images != null) {
          _validateItemSelector(images, 'contentRule.images', issues);
          final fields = _requireMap(
            images,
            'fields',
            issues,
            pathPrefix: 'contentRule.images',
          );
          if (fields != null) {
            _validateExtractorField(
              fields,
              'url',
              'contentRule.images.fields.url',
              issues,
            );
          }
        }
        if (contentRule.containsKey('video')) {
          issues.add(
            const RuleValidationIssue(
              code: 'content_branch_mismatch',
              path: 'contentRule.video',
              message: 'video branch must not exist for comic/gallery.',
            ),
          );
        }
      }

      if (contentType == 'video') {
        final video = _requireMap(
          contentRule,
          'video',
          issues,
          pathPrefix: 'contentRule',
        );
        if (video != null) {
          _validateExtractorField(
            video,
            'url',
            'contentRule.video.url',
            issues,
          );
        }
        if (contentRule.containsKey('images')) {
          issues.add(
            const RuleValidationIssue(
              code: 'content_branch_mismatch',
              path: 'contentRule.images',
              message: 'images branch must not exist for video.',
            ),
          );
        }
      }

      final secondLevel = contentRule['secondLevel'];
      if (secondLevel != null) {
        if (secondLevel is! Map<String, dynamic>) {
          issues.add(
            const RuleValidationIssue(
              code: 'invalid_type',
              path: 'contentRule.secondLevel',
              message: 'secondLevel must be an object.',
            ),
          );
        } else if (secondLevel.containsKey('secondLevel')) {
          issues.add(
            const RuleValidationIssue(
              code: 'nested_second_level',
              path: 'contentRule.secondLevel.secondLevel',
              message: 'Only one secondLevel hop is allowed.',
            ),
          );
        }
      }
    }

    return RuleValidationResult(issues: issues);
  }

  void _validateItemSelector(
    Map<String, dynamic> parent,
    String pathPrefix,
    List<RuleValidationIssue> issues,
  ) {
    final item = _requireMap(parent, 'item', issues, pathPrefix: pathPrefix);
    if (item == null) {
      return;
    }
    _requireString(item, 'selector', issues, pathPrefix: '$pathPrefix.item');
  }

  void _validateOptionalExtractorField(
    Map<String, dynamic> parent,
    String key,
    String path,
    List<RuleValidationIssue> issues,
  ) {
    if (!parent.containsKey(key) || parent[key] == null) {
      return;
    }
    _validateExtractor(parent[key], path, issues);
  }

  void _validateExtractorField(
    Map<String, dynamic> parent,
    String key,
    String path,
    List<RuleValidationIssue> issues,
  ) {
    if (!parent.containsKey(key)) {
      issues.add(
        RuleValidationIssue(
          code: 'missing_field',
          path: path,
          message: 'Missing required field: $path',
        ),
      );
      return;
    }
    _validateExtractor(parent[key], path, issues);
  }

  void _validateExtractor(
    dynamic value,
    String path,
    List<RuleValidationIssue> issues,
  ) {
    if (value is! Map<String, dynamic>) {
      issues.add(
        RuleValidationIssue(
          code: 'invalid_type',
          path: path,
          message: '$path must be an object.',
        ),
      );
      return;
    }

    final selector = value['selector'];
    if (selector is! String) {
      issues.add(
        RuleValidationIssue(
          code: 'missing_field',
          path: '$path.selector',
          message: 'Missing required string: $path.selector',
        ),
      );
    }

    final fn = value['function'];
    if (fn is! String || !_supportedExtractorFunctions.contains(fn)) {
      issues.add(
        RuleValidationIssue(
          code: 'invalid_extractor_function',
          path: '$path.function',
          message: 'function must be one of text/html/attr.',
        ),
      );
    }

    if (fn == 'attr') {
      final param = value['param'];
      if (param is! String || param.isEmpty) {
        issues.add(
          RuleValidationIssue(
            code: 'missing_attr_param',
            path: '$path.param',
            message: 'param is required when function=attr.',
          ),
        );
      }
    }
  }

  void _requireObject(
    Map<String, dynamic> map,
    String pathPrefix,
    List<RuleValidationIssue> issues,
  ) {
    if (map.isEmpty) {
      issues.add(
        RuleValidationIssue(
          code: 'empty_object',
          path: pathPrefix.isEmpty ? r'$' : pathPrefix,
          message: 'Rule object must not be empty.',
        ),
      );
    }
  }

  Map<String, dynamic>? _requireMap(
    Map<String, dynamic> parent,
    String key,
    List<RuleValidationIssue> issues, {
    String? pathPrefix,
  }) {
    final path = pathPrefix == null ? key : '$pathPrefix.$key';
    if (!parent.containsKey(key)) {
      issues.add(
        RuleValidationIssue(
          code: 'missing_field',
          path: path,
          message: 'Missing required field: $path',
        ),
      );
      return null;
    }
    final value = parent[key];
    if (value is! Map<String, dynamic>) {
      issues.add(
        RuleValidationIssue(
          code: 'invalid_type',
          path: path,
          message: '$path must be an object.',
        ),
      );
      return null;
    }
    return value;
  }

  String? _requireString(
    Map<String, dynamic> parent,
    String key,
    List<RuleValidationIssue> issues, {
    String? pathPrefix,
    String? expectedValue,
  }) {
    final path = pathPrefix == null ? key : '$pathPrefix.$key';
    if (!parent.containsKey(key)) {
      issues.add(
        RuleValidationIssue(
          code: 'missing_field',
          path: path,
          message: 'Missing required field: $path',
        ),
      );
      return null;
    }
    final value = parent[key];
    if (value is! String || value.isEmpty) {
      issues.add(
        RuleValidationIssue(
          code: 'invalid_type',
          path: path,
          message: '$path must be a non-empty string.',
        ),
      );
      return null;
    }
    if (expectedValue != null && value != expectedValue) {
      issues.add(
        RuleValidationIssue(
          code: 'unsupported_value',
          path: path,
          message: '$path must be "$expectedValue".',
        ),
      );
    }
    return value;
  }

  bool _isAbsoluteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.isAbsolute;
  }
}

class RuleValidationResult {
  const RuleValidationResult({required this.issues});

  final List<RuleValidationIssue> issues;

  bool get isValid => issues.isEmpty;
}

class RuleValidationIssue {
  const RuleValidationIssue({
    required this.code,
    required this.path,
    required this.message,
  });

  final String code;
  final String path;
  final String message;
}

const _supportedContentTypes = <String>{'comic', 'gallery', 'video'};
const _supportedExtractorFunctions = <String>{'text', 'html', 'attr'};
