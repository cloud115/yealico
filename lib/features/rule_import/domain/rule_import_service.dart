import 'dart:convert';

import '../../../core/models/rule_import_request.dart';
import '../data/rule_raw_fetcher.dart';
import 'rule_validator.dart';

class RuleImportService {
  RuleImportService({RuleRawFetcher? fetcher, RuleValidator? validator})
    : _fetcher = fetcher ?? const RuleRawFetcher(),
      _validator = validator ?? RuleValidator();

  final RuleRawFetcher _fetcher;
  final RuleValidator _validator;

  Future<RuleImportRequest> importFromUrl(String rawUrl) async {
    final trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      throw const RuleImportException('Please input a GitHub Raw URL.');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.isAbsolute) {
      throw const RuleImportException('Invalid URL format.');
    }

    if (!_isGitHubRawHost(uri.host)) {
      throw const RuleImportException(
        'Only GitHub Raw URLs are supported in MVP.',
      );
    }

    final response = await _fetcher.fetch(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RuleImportException(
        'Download failed with status ${response.statusCode}.',
      );
    }

    final normalized = _preprocess(response.body);
    if (normalized.isEmpty) {
      throw const RuleImportException('Downloaded rule file is empty.');
    }

    final decoded = jsonDecode(normalized);
    if (decoded is! Map<String, dynamic>) {
      throw const RuleImportException('Rule JSON root must be an object.');
    }

    final result = _validator.validate(decoded);
    if (!result.isValid) {
      throw RuleValidationException(result.issues);
    }

    return RuleImportRequest(
      sourceUrl: uri.toString(),
      rawJson: normalized,
      parsedJson: decoded,
      importedAt: DateTime.now().toUtc(),
    );
  }

  bool _isGitHubRawHost(String host) {
    final lower = host.toLowerCase();
    return lower == 'raw.githubusercontent.com' ||
        lower.endsWith('.githubusercontent.com');
  }

  String _preprocess(String input) {
    final withoutBom = input.startsWith('\uFEFF') ? input.substring(1) : input;
    return withoutBom.trim();
  }
}

class RuleImportException implements Exception {
  const RuleImportException(this.message);

  final String message;

  @override
  String toString() => 'RuleImportException: $message';
}

class RuleValidationException implements Exception {
  const RuleValidationException(this.issues);

  final List<RuleValidationIssue> issues;

  String get message {
    if (issues.isEmpty) {
      return 'Rule validation failed.';
    }
    final first = issues.first;
    if (issues.length == 1) {
      return '[${first.path}] ${first.message}';
    }
    return '[${first.path}] ${first.message} (+${issues.length - 1} more)';
  }

  @override
  String toString() => 'RuleValidationException: $message';
}
