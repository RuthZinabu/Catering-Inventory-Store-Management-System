import '../models/store_model.dart';
import 'api/base_api_service.dart';
import 'api/api_exception.dart';

class StoreService extends BaseApiService
    implements CrudRepository<Store, String> {
  static StoreService? _instance;
  static StoreService get instance {
    _instance ??= StoreService._internal();
    return _instance!;
  }

  StoreService._internal();

  @override
  Future<PaginatedResult<Store>> getAll({ListQueryParams? queryParams}) async {
    return await executePaginatedRequest<Store>(
      () => apiClient.get<Map<String, dynamic>>(
        '/stores',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => Store.fromJson(json),
      errorContext: 'Failed to fetch stores',
    );
  }

  @override
  Future<Store?> getById(String id) async {
    try {
      return await executeRequest<Store>(
        () => apiClient.get<Store>(
          '/stores/$id',
          fromJson: (json) => Store.fromJson(json),
        ),
        errorContext: 'Failed to fetch store',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Store> create(Map<String, dynamic> data) async {
    return await executeRequest<Store>(
      () => apiClient.post<Store>(
        '/stores',
        data: data,
        fromJson: (json) => Store.fromJson(json),
      ),
      errorContext: 'Failed to create store',
    );
  }

  @override
  Future<Store> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<Store>(
      () => apiClient.put<Store>(
        '/stores/$id',
        data: data,
        fromJson: (json) => Store.fromJson(json),
      ),
      errorContext: 'Failed to update store',
    );
  }

  @override
  Future<void> delete(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/stores/$id'),
      errorContext: 'Failed to delete store',
    );
  }

  @override
  Future<List<Store>> search(String query, {int? limit}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/stores',
      queryParameters: {'search': query, if (limit != null) 'per_page': limit},
    );

    if (response.isSuccess && response.data != null) {
      final itemsData = response.data!['stores'] ?? [];
      return (itemsData as List)
          .cast<Map<String, dynamic>>()
          .map((json) => Store.fromJson(json))
          .toList();
    }

    throw ApiException(
      message: response.message ?? 'Search failed',
      errors: response.errors,
    );
  }

  /// Get available store types
  Future<List<Map<String, String>>> getStoreTypes() async {
    return await executeRequest<List<Map<String, String>>>(
      () => apiClient.get<List<Map<String, String>>>(
        '/stores/types',
        fromJson: (json) => (json as List)
            .cast<Map<String, dynamic>>()
            .map((item) => Map<String, String>.from(item))
            .toList(),
      ),
      errorContext: 'Failed to fetch store types',
    );
  }

  /// Get stores by type
  Future<List<Store>> getByType(String type) async {
    final result = await getAll(
      queryParams: ListQueryParams(filters: {'type': type}),
    );
    return result.items;
  }

  /// Get stores by level
  Future<List<Store>> getByLevel(int level) async {
    final result = await getAll(
      queryParams: ListQueryParams(filters: {'level': level}),
    );
    return result.items;
  }

  /// Get child stores of a parent store
  Future<List<Store>> getChildStores(String parentStoreId) async {
    final result = await getAll(
      queryParams: ListQueryParams(filters: {'parent_store_id': parentStoreId}),
    );
    return result.items;
  }

  /// Get stores that user can access
  Future<List<Store>> getAccessibleStores({String? userId}) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) {
      queryParams['user_id'] = userId;
    }

    final result = await getAll(
      queryParams: ListQueryParams(filters: queryParams),
    );
    return result.items;
  }
}
