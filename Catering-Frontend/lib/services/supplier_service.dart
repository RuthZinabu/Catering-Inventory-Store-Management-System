import '../models/inventory_models.dart';
import 'api/base_api_service.dart';
import 'api/api_exception.dart';

class SupplierService extends BaseApiService
    implements CrudRepository<Supplier, String> {
  static SupplierService? _instance;
  static SupplierService get instance {
    _instance ??= SupplierService._internal();
    return _instance!;
  }

  SupplierService._internal();

  @override
  Future<PaginatedResult<Supplier>> getAll({
    ListQueryParams? queryParams,
  }) async {
    return await executePaginatedRequest<Supplier>(
      () => apiClient.get<Map<String, dynamic>>(
        '/suppliers',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => Supplier.fromJson(json),
      errorContext: 'Failed to fetch suppliers',
    );
  }

  @override
  Future<Supplier?> getById(String id) async {
    try {
      return await executeRequest<Supplier>(
        () => apiClient.get<Supplier>(
          '/suppliers/$id',
          fromJson: (json) => Supplier.fromJson(json),
        ),
        errorContext: 'Failed to fetch supplier',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<Supplier> create(Map<String, dynamic> data) async {
    return await executeRequest<Supplier>(
      () => apiClient.post<Supplier>(
        '/suppliers',
        data: data,
        fromJson: (json) => Supplier.fromJson(json),
      ),
      errorContext: 'Failed to create supplier',
    );
  }

  @override
  Future<Supplier> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<Supplier>(
      () => apiClient.put<Supplier>(
        '/suppliers/$id',
        data: data,
        fromJson: (json) => Supplier.fromJson(json),
      ),
      errorContext: 'Failed to update supplier',
    );
  }

  @override
  Future<void> delete(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/suppliers/$id'),
      errorContext: 'Failed to delete supplier',
    );
  }

  @override
  Future<List<Supplier>> search(String query, {int? limit}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/suppliers',
      queryParameters: {'search': query, if (limit != null) 'per_page': limit},
    );

    if (response.isSuccess && response.data != null) {
      final itemsData = response.data!['suppliers'] ?? [];
      return (itemsData as List)
          .cast<Map<String, dynamic>>()
          .map((json) => Supplier.fromJson(json))
          .toList();
    }

    throw ApiException(
      message: response.message ?? 'Search failed',
      errors: response.errors,
    );
  }

  /// Get suppliers by status
  Future<List<Supplier>> getByStatus(String status) async {
    final result = await getAll(
      queryParams: ListQueryParams(filters: {'status': status}),
    );
    return result.items;
  }

  /// Get active suppliers
  Future<List<Supplier>> getActiveSuppliers() async {
    return await getByStatus('Active');
  }

  /// Get suppliers with outstanding balances
  Future<List<Supplier>> getSuppliersWithOutstandingBalance() async {
    final result = await getAll(
      queryParams: ListQueryParams(filters: {'has_outstanding_balance': true}),
    );
    return result.items;
  }
}
