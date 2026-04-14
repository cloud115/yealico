import 'package:http/http.dart' as http;

class RuleRawFetcher {
  const RuleRawFetcher({http.Client? client}) : _client = client;

  final http.Client? _client;

  Future<RuleRawResponse> fetch(Uri uri) async {
    final client = _client ?? http.Client();
    try {
      final response = await client.get(uri);
      return RuleRawResponse(
        statusCode: response.statusCode,
        body: response.body,
      );
    } finally {
      if (_client == null) {
        client.close();
      }
    }
  }
}

class RuleRawResponse {
  const RuleRawResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}
