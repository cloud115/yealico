class SiteVerificationPendingException implements Exception {
  const SiteVerificationPendingException();

  @override
  String toString() => 'SiteVerificationPendingException';
}

class ProtectedImageBlockedException implements Exception {
  const ProtectedImageBlockedException();

  @override
  String toString() => 'ProtectedImageBlockedException';
}

class DecryptScriptExecutionException implements Exception {
  const DecryptScriptExecutionException();

  @override
  String toString() => 'DecryptScriptExecutionException';
}

class SiteRateLimitedException implements Exception {
  const SiteRateLimitedException();

  @override
  String toString() => 'SiteRateLimitedException';
}
