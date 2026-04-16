class RenderedPageResult {
  const RenderedPageResult({
    required this.finalUri,
    required this.html,
    required this.title,
    required this.cookies,
    required this.challengeDetected,
    this.decryptResult,
  });

  final Uri finalUri;
  final String html;
  final String title;
  final String cookies;
  final bool challengeDetected;
  final String? decryptResult;
}
