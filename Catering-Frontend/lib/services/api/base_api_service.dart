import 'api_client.dart';
import 'api_response.dart';
import 'api_exception.dart';

/// Base class for all API services
abstract class BaseApiService {
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get the API client instance
  ApiClient get apiClient => _apiClient;

  /// Handle common API operations with consistent error handling
  Future<T> executeRequest<T>(
    Future<ApiResponse<T>> Function() request, {
    String? errorContext,
  }) async {
    try {
      final response = await request();
      
      if (response.isSuccess) {
        if (response.data != null) {
          return response.data!;
        }
        if (T.toString() == 'void') {
          return null as T;
        }
      }

      throw ApiException(
        message: response.message ?? 'Request failed',
        errors: response.errors,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      final contextMessage = errorContext != null 
          ? '$errorContext: ${e.toString()}'
          : e.toString();
      throw ApiException(message: contextMessage);
    }
  }

  /// Handle paginated requests
  Future<PaginatedResult<T>> executePaginatedRequest<T>(
    Future<ApiResponse<Map<String, dynamic>>> Function() request, {
    required T Function(Map<String, dynamic>) itemFromJson,
    String? errorContext,
  }) async {
    try {
      final response = await request();
      
      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        final itemsData = data['items'] ?? data['data'] ?? data['suppliers'] ?? [];
        
        final items = (itemsData as List)
            .cast<Map<String, dynamic>>()
            .map(itemFromJson)
            .toList();
            
        return PaginatedResult<T>(
          items: items,
          pagination: response.pagination,
        );
      } else {
        throw ApiException(
          message: response.message ?? 'Request failed',
          errors: response.errors,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      final contextMessage = errorContext != null 
          ? '$errorContext: ${e.toString()}'
          : e.toString();
      throw ApiException(message: contextMessage);
    }
  }

  /// Build query parameters for filtering and pagination
  Map<String, dynamic> buildQueryParams({
    String? search,
    Map<String, dynamic>? filters,
    int? page,
    int? perPage,
    String? sortBy,
    String? sortOrder,
  }) {
    final params = <String, dynamic>{};
    
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    
    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          params[key] = value;
        }
      });
    }
    
    if (page != null && page > 0) {
      params['page'] = page;
    }
    
    if (perPage != null && perPage > 0) {
      params['per_page'] = perPage;
    }
    
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sort_by'] = sortBy;
    }
    
    if (sortOrder != null && sortOrder.isNotEmpty) {
      params['sort_order'] = sortOrder;
    }
    
    return params;
  }
}

/// Result wrapper for paginated API responses
class PaginatedResult<T> {
  final List<T> items;
  final PaginationMeta? pagination;

  const PaginatedResult({
    required this.items,
    this.pagination,
  });

  /// Check if there are more pages available
  bool get hasNextPage => pagination?.hasNextPage ?? false;
  
  /// Check if there are previous pages
  bool get hasPreviousPage => pagination?.hasPreviousPage ?? false;
  
  /// Get total number of items
  int get total => pagination?.total ?? items.length;
  
  /// Get current page number
  int get currentPage => pagination?.currentPage ?? 1;
  
  /// Get total number of pages
  int get lastPage => pagination?.lastPage ?? 1;
}

/// Common query parameters for list requests
class ListQueryParams {
  final String? search;
  final int? page;
  final int? perPage;
  final String? sortBy;
  final String? sortOrder;
  final Map<String, dynamic>? filters;

  const ListQueryParams({
    this.search,
    this.page,
    this.perPage,
    this.sortBy,
    this.sortOrder,
    this.filters,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    
    if (search != null) map['search'] = search;
    if (page != null) map['page'] = page;
    if (perPage != null) map['per_page'] = perPage;
    if (sortBy != null) map['sort_by'] = sortBy;
    if (sortOrder != null) map['sort_order'] = sortOrder;
    
    if (filters != null) {
      map.addAll(filters!);
    }
    
    return map;
  }
}

/// Standard CRUD operations interface
abstract class CrudRepository<T, ID> {
  /// Get all items with optional filtering and pagination
  Future<PaginatedResult<T>> getAll({
    ListQueryParams? queryParams,
  });

  /// Get a single item by ID
  Future<T?> getById(ID id);

  /// Create a new item
  Future<T> create(Map<String, dynamic> data);

  /// Update an existing item
  Future<T> update(ID id, Map<String, dynamic> data);

  /// Delete an item by ID
  Future<void> delete(ID id);

  /// Search items
  Future<List<T>> search(String query, {int? limit});
}

/// Repository interface for items with store context
abstract class StoreContextRepository<T, ID> extends CrudRepository<T, ID> {
  /// Get items for a specific store
  Future<PaginatedResult<T>> getByStore(
    String storeId, {
    ListQueryParams? queryParams,
  });

  /// Get a specific item in a store context
  Future<T?> getByIdInStore(String storeId, ID id);
  
  /// Create item in store context
  Future<T> createInStore(String storeId, Map<String, dynamic> data);
  
  /// Update item in store context
  Future<T> updateInStore(String storeId, ID id, Map<String, dynamic> data);
  
  /// Delete item from store
  Future<void> deleteFromStore(String storeId, ID id);
}

/// Interface for repositories that support offline caching
abstract class CacheableRepository<T> {
  /// Cache data locally
  Future<void> cacheData(List<T> items);
  
  /// Get cached data
  Future<List<T>> getCachedData();
  
  /// Clear cached data
  Future<void> clearCache();
  
  /// Check if cache is valid
  Future<bool> isCacheValid();
}