import 'package:catering_inventory_store_management_system/services/api/api_response_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponseCache', () {
    late DateTime now;
    late ApiResponseCache<String> cache;

    setUp(() {
      now = DateTime.utc(2026, 10, 5);
      cache = ApiResponseCache<String>(
        validDuration: const Duration(minutes: 5),
        clock: () => now,
      );
    });

    test('reuses an inventory response until it expires', () {
      cache.put('/stock?store_id=store-1', 'stock-v1');

      expect(cache.get('/stock?store_id=store-1'), 'stock-v1');

      now = now.add(const Duration(minutes: 5));
      expect(cache.get('/stock?store_id=store-1'), isNull);
    });

    test('a successful edit invalidation makes the next read fetch fresh stock',
        () async {
      const key = '/stock?store_id=store-1';
      var serverStock = 'stock-v1';
      var requestCount = 0;

      Future<String> fetchStock() async {
        final cached = cache.get(key);
        if (cached != null) return cached;

        requestCount++;
        cache.put(key, serverStock);
        return serverStock;
      }

      expect(await fetchStock(), 'stock-v1');
      expect(await fetchStock(), 'stock-v1');
      expect(requestCount, 1);

      serverStock = 'stock-v2';
      cache.clear(); // Mutation requests invalidate cached GET responses.

      expect(await fetchStock(), 'stock-v2');
      expect(requestCount, 2);
    });

    test('logout clears cached data before another session reads inventory',
        () async {
      const key = '/stock?store_id=store-1';
      var accountStock = 'first-account-stock';
      var requestCount = 0;

      Future<String> fetchStock() async {
        final cached = cache.get(key);
        if (cached != null) return cached;

        requestCount++;
        cache.put(key, accountStock);
        return accountStock;
      }

      expect(await fetchStock(), 'first-account-stock');
      expect(await fetchStock(), 'first-account-stock');
      expect(requestCount, 1);

      accountStock = 'second-account-stock';
      cache.clear(); // Session cleanup invalidates the whole response cache.

      expect(await fetchStock(), 'second-account-stock');
      expect(requestCount, 2);
    });
  });
}
