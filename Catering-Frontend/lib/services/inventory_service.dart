import 'package:catering_inventory_store_management_system/services/api/api_exception.dart';

import '../models/inventory_models.dart';
import 'api/base_api_service.dart';
import 'api/api_response.dart';

class InventoryService extends BaseApiService
    implements CrudRepository<InventoryItem, String> {
  static InventoryService? _instance;
  static InventoryService get instance {
    _instance ??= InventoryService._internal();
    return _instance!;
  }

  InventoryService._internal();

  @override
  Future<PaginatedResult<InventoryItem>> getAll({
    ListQueryParams? queryParams,
  }) async {
    return await executePaginatedRequest<InventoryItem>(
      () => apiClient.get<Map<String, dynamic>>(
        '/items',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => InventoryItem.fromJson(json),
      errorContext: 'Failed to fetch items',
    );
  }

  @override
  Future<InventoryItem?> getById(String id) async {
    try {
      return await executeRequest<InventoryItem>(
        () => apiClient.get<InventoryItem>(
          '/items/$id',
          fromJson: (json) => InventoryItem.fromJson(json),
        ),
        errorContext: 'Failed to fetch item',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<InventoryItem> create(Map<String, dynamic> data) async {
    return await executeRequest<InventoryItem>(
      () => apiClient.post<InventoryItem>(
        '/items',
        data: data,
        fromJson: (json) => InventoryItem.fromJson(json),
      ),
      errorContext: 'Failed to create item',
    );
  }

  @override
  Future<InventoryItem> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<InventoryItem>(
      () => apiClient.put<InventoryItem>(
        '/items/$id',
        data: data,
        fromJson: (json) => InventoryItem.fromJson(json),
      ),
      errorContext: 'Failed to update item',
    );
  }

  @override
  Future<void> delete(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/items/$id'),
      errorContext: 'Failed to delete item',
    );
  }

  @override
  Future<List<InventoryItem>> search(String query, {int? limit}) async {
    final response = await apiClient.get<List<InventoryItem>>(
      '/items/search',
      queryParameters: {
        'q': query,
        if (limit != null) 'limit': limit,
      },
      fromJson: (json) => (json as List)
          .cast<Map<String, dynamic>>()
          .map((item) => InventoryItem.fromJson(item))
          .toList(),
    );

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.message ?? 'Search failed',
      errors: response.errors,
    );
  }

  /// Get items by category
  Future<List<InventoryItem>> getByCategory(String category) async {
    final result = await getAll(
      queryParams: ListQueryParams(
        filters: {'category': category},
      ),
    );
    return result.items;
  }

  /// Get items by type
  Future<List<InventoryItem>> getByType(String type) async {
    final result = await getAll(
      queryParams: ListQueryParams(
        filters: {'type': type},
      ),
    );
    return result.items;
  }

  /// Get low stock items
  Future<List<InventoryItem>> getLowStockItems() async {
    final result = await getAll(
      queryParams: ListQueryParams(
        filters: {'low_stock': true},
      ),
    );
    return result.items;
  }

  /// Get available categories
  Future<List<String>> getCategories({String? type}) async {
    final queryParams = <String, dynamic>{};
    if (type != null) {
      queryParams['type'] = type;
    }

    return await executeRequest<List<String>>(
      () => apiClient.get<List<String>>(
        '/items/categories',
        queryParameters: queryParams,
        fromJson: (json) => (json as List).cast<String>(),
      ),
      errorContext: 'Failed to fetch categories',
    );
  }

  /// Get available item types
  Future<List<Map<String, String>>> getItemTypes() async {
    return await executeRequest<List<Map<String, String>>>(
      () => apiClient.get<List<Map<String, String>>>(
        '/items/types',
        fromJson: (json) => (json as List)
            .cast<Map<String, dynamic>>()
            .map((item) => Map<String, String>.from(item))
            .toList(),
      ),
      errorContext: 'Failed to fetch item types',
    );
  }
}
