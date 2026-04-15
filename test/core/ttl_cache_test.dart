import 'package:flutter_test/flutter_test.dart';
import 'package:yealico/core/cache/ttl_cache.dart';

void main() {
  test('returns cached value before ttl expiration', () {
    final cache = TtlCache<String, String>(ttl: const Duration(seconds: 5));
    cache.set('k', 'v');
    expect(cache.get('k'), 'v');
  });

  test('clear removes cached values', () {
    final cache = TtlCache<String, String>(ttl: const Duration(seconds: 5));
    cache.set('k', 'v');
    cache.clear();
    expect(cache.get('k'), isNull);
  });
}
