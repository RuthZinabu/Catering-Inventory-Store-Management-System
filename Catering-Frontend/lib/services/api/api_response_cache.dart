/// Small bounded in-memory cache for successful API GET response bodies.
class ApiResponseCache<T> {
  final Duration validDuration;
  final int maxEntries;
  final DateTime Function() _clock;
  final Map<String, _CacheEntry<T>> _entries = {};

  ApiResponseCache({
    required this.validDuration,
    this.maxEntries = 100,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  T? get(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_clock().difference(entry.cachedAt) >= validDuration) {
      _entries.remove(key);
      return null;
    }
    return entry.value;
  }

  void put(String key, T value) {
    _entries.remove(key);
    _entries[key] = _CacheEntry(value, _clock());
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void remove(String key) => _entries.remove(key);

  void clear() => _entries.clear();
}

class _CacheEntry<T> {
  final T value;
  final DateTime cachedAt;

  const _CacheEntry(this.value, this.cachedAt);
}
