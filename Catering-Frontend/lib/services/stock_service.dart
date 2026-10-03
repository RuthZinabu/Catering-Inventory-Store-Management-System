import '../models/stock_models.dart';
import 'api/base_api_service.dart';
import 'api/api_exception.dart';

class StockService extends BaseApiService
    implements StoreContextRepository<StockItem, String> {
  static StockService? _instance;
  static StockService get instance {
    _instance ??= StockService._internal();
    return _instance!;
  }

  StockService._internal();

  @override
  Future<PaginatedResult<StockItem>> getAll({
    ListQueryParams? queryParams,
  }) async {
    // This would get stock across all accessible stores
    return await executePaginatedRequest<StockItem>(
      () => apiClient.get<Map<String, dynamic>>(
        '/stock',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => _stockItemFromJson(json),
      errorContext: 'Failed to fetch stock',
    );
  }

  @override
  Future<PaginatedResult<StockItem>> getByStore(
    String storeId, {
    ListQueryParams? queryParams,
  }) async {
    return await executePaginatedRequest<StockItem>(
      () => apiClient.get<Map<String, dynamic>>(
        '/stores/$storeId/stock',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => _stockItemFromJson(json),
      errorContext: 'Failed to fetch store stock',
    );
  }

  @override
  Future<StockItem?> getById(String id) async {
    try {
      return await executeRequest<StockItem>(
        () => apiClient.get<StockItem>(
          '/stock/$id',
          fromJson: (json) => _stockItemFromJson(json),
        ),
        errorContext: 'Failed to fetch stock item',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<StockItem?> getByIdInStore(String storeId, String id) async {
    try {
      return await executeRequest<StockItem>(
        () => apiClient.get<StockItem>(
          '/stores/$storeId/stock/$id',
          fromJson: (json) => _stockItemFromJson(json),
        ),
        errorContext: 'Failed to fetch store stock item',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<StockItem> create(Map<String, dynamic> data) async {
    return await executeRequest<StockItem>(
      () => apiClient.post<StockItem>(
        '/stock',
        data: data,
        fromJson: (json) => _stockItemFromJson(json),
      ),
      errorContext: 'Failed to create stock item',
    );
  }

  @override
  Future<StockItem> createInStore(
    String storeId,
    Map<String, dynamic> data,
  ) async {
    return await executeRequest<StockItem>(
      () => apiClient.post<StockItem>(
        '/stores/$storeId/stock',
        data: data,
        fromJson: (json) => _stockItemFromJson(json),
      ),
      errorContext: 'Failed to create store stock item',
    );
  }

  @override
  Future<StockItem> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<StockItem>(
      () => apiClient.put<StockItem>(
        '/stock/$id',
        data: data,
        fromJson: (json) => _stockItemFromJson(json),
      ),
      errorContext: 'Failed to update stock item',
    );
  }

  @override
  Future<StockItem> updateInStore(
    String storeId,
    String id,
    Map<String, dynamic> data,
  ) async {
    return await executeRequest<StockItem>(
      () => apiClient.put<StockItem>(
        '/stores/$storeId/stock/$id',
        data: data,
        fromJson: (json) => _stockItemFromJson(json),
      ),
      errorContext: 'Failed to update store stock item',
    );
  }

  @override
  Future<void> delete(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/stock/$id'),
      errorContext: 'Failed to delete stock item',
    );
  }

  @override
  Future<void> deleteFromStore(String storeId, String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/stores/$storeId/stock/$id'),
      errorContext: 'Failed to delete store stock item',
    );
  }

  @override
  Future<List<StockItem>> search(String query, {int? limit}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/stock/search',
      queryParameters: {'q': query, if (limit != null) 'limit': limit},
    );

    if (response.isSuccess && response.data != null) {
      final itemsData = response.data!['items'] ?? [];
      return (itemsData as List)
          .cast<Map<String, dynamic>>()
          .map((json) => _stockItemFromJson(json))
          .toList();
    }

    throw ApiException(
      message: response.message ?? 'Search failed',
      errors: response.errors,
    );
  }

  /// Get stock movements
  Future<PaginatedResult<StockMovementEntry>> getStockMovements({
    String? storeId,
    String? itemId,
    ListQueryParams? queryParams,
  }) async {
    final params = queryParams?.toMap() ?? <String, dynamic>{};
    if (storeId != null) params['store_id'] = storeId;
    if (itemId != null) params['item_id'] = itemId;

    return await executePaginatedRequest<StockMovementEntry>(
      () => apiClient.get<Map<String, dynamic>>(
        '/stock-movements',
        queryParameters: params,
      ),
      itemFromJson: (json) => StockMovementEntry.fromJson(
        normalizeStockMovementJson(json),
      ),
      errorContext: 'Failed to fetch stock movements',
    );
  }

  /// Record stock movement
  Future<StockMovementEntry> recordMovement(Map<String, dynamic> data) async {
    return await executeRequest<StockMovementEntry>(
      () => apiClient.post<StockMovementEntry>(
        '/stock-movements',
        data: data,
        fromJson: (json) => StockMovementEntry.fromJson(
          normalizeStockMovementJson(Map<String, dynamic>.from(json as Map)),
        ),
      ),
      errorContext: 'Failed to record stock movement',
    );
  }

  /// Get low stock items
  Future<List<StockItem>> getLowStockItems({String? storeId}) async {
    final params = <String, dynamic>{'low_stock': true};
    if (storeId != null) params['store_id'] = storeId;

    final result = await getAll(queryParams: ListQueryParams(filters: params));
    return result.items;
  }

  /// Get stock by category
  Future<List<StockItem>> getByCategory(
    StockCategory category, {
    String? storeId,
  }) async {
    final params = <String, dynamic>{'category': category.name};
    if (storeId != null) params['store_id'] = storeId;

    final result = await getAll(queryParams: ListQueryParams(filters: params));
    return result.items;
  }

  /// Get food stock items
  Future<List<FoodStockItem>> getFoodStock({String? storeId}) async {
    final stockItems = await getByCategory(
      StockCategory.food,
      storeId: storeId,
    );
    return stockItems.whereType<FoodStockItem>().toList();
  }

  /// Get catering stock items
  Future<List<CateringStockItem>> getCateringStock({String? storeId}) async {
    final stockItems = await getByCategory(
      StockCategory.catering,
      storeId: storeId,
    );
    return stockItems.whereType<CateringStockItem>().toList();
  }

  /// Get electronics stock items
  Future<List<ElectronicsStockItem>> getElectronicsStock({
    String? storeId,
  }) async {
    final stockItems = await getByCategory(
      StockCategory.electronics,
      storeId: storeId,
    );
    return stockItems.whereType<ElectronicsStockItem>().toList();
  }

  /// Convert API response to appropriate stock item type
  StockItem _stockItemFromJson(Map<String, dynamic> json) {
    final normalizedJson = normalizeStockItemJson(json);
    final categoryName = normalizedJson['stock_category'];
    final category = StockCategory.values.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => StockCategory.food,
    );

    switch (category) {
      case StockCategory.food:
        return FoodStockItem.fromJson(normalizedJson);
      case StockCategory.catering:
        return CateringStockItem.fromJson(normalizedJson);
      case StockCategory.electronics:
        return ElectronicsStockItem.fromJson(normalizedJson);
      default:
        return StockItem.fromJson(normalizedJson);
    }
  }
}
