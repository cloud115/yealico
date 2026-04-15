class TtlCache<K, V> {
  TtlCache({required this.ttl});

  final Duration ttl;
  final Map<K, _CacheEntry<V>> _map = <K, _CacheEntry<V>>{};

  V? get(K key) {
    final entry = _map[key];
    if (entry == null) {
      return null;
    }
    final now = DateTime.now().toUtc();
    if (now.isAfter(entry.expiresAt)) {
      _map.remove(key);
      return null;
    }
    return entry.value;
  }

  void set(K key, V value) {
    final now = DateTime.now().toUtc();
    _map[key] = _CacheEntry<V>(value: value, expiresAt: now.add(ttl));
  }

  void clear() {
    _map.clear();
  }
}

class _CacheEntry<V> {
  const _CacheEntry({required this.value, required this.expiresAt});

  final V value;
  final DateTime expiresAt;
}
