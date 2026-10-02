import '../models/inventory_models.dart';
import 'api/base_api_service.dart';
import 'api/api_exception.dart';

class UserService extends BaseApiService
    implements CrudRepository<AppUser, String> {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._internal();
    return _instance!;
  }

  UserService._internal();

  @override
  Future<PaginatedResult<AppUser>> getAll({
    ListQueryParams? queryParams,
  }) async {
    return await executePaginatedRequest<AppUser>(
      () => apiClient.get<Map<String, dynamic>>(
        '/users',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: (json) => AppUser.fromJson(json),
      errorContext: 'Failed to fetch users',
    );
  }

  @override
  Future<AppUser?> getById(String id) async {
    try {
      return await executeRequest<AppUser>(
        () => apiClient.get<AppUser>(
          '/users/$id',
          fromJson: (json) => AppUser.fromJson(json),
        ),
        errorContext: 'Failed to fetch user',
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AppUser> create(Map<String, dynamic> data) async {
    return await executeRequest<AppUser>(
      () => apiClient.post<AppUser>(
        '/users',
        data: data,
        fromJson: (json) => AppUser.fromJson(json),
      ),
      errorContext: 'Failed to create user',
    );
  }

  @override
  Future<AppUser> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<AppUser>(
      () => apiClient.put<AppUser>(
        '/users/$id',
        data: data,
        fromJson: (json) => AppUser.fromJson(json),
      ),
      errorContext: 'Failed to update user',
    );
  }

  @override
  Future<void> delete(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/users/$id'),
      errorContext: 'Failed to delete user',
    );
  }

  @override
  Future<List<AppUser>> search(String query, {int? limit}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/users',
      queryParameters: {'search': query, if (limit != null) 'per_page': limit},
    );

    if (response.isSuccess && response.data != null) {
      final itemsData = response.data!['users'] ?? [];
      return (itemsData as List)
          .cast<Map<String, dynamic>>()
          .map((json) => AppUser.fromJson(json))
          .toList();
    }

    throw ApiException(
      message: response.message ?? 'Search failed',
      errors: response.errors,
    );
  }

  /// Get available user roles
  Future<List<Map<String, String>>> getRoles() async {
    return await executeRequest<List<Map<String, String>>>(
      () => apiClient.get<List<Map<String, String>>>(
        '/users/roles',
        fromJson: (json) => (json as List)
            .cast<Map<String, dynamic>>()
            .map((item) => Map<String, String>.from(item))
            .toList(),
      ),
      errorContext: 'Failed to fetch user roles',
    );
  }

  /// Get available permissions
  Future<List<String>> getPermissions() async {
    return await executeRequest<List<String>>(
      () => apiClient.get<List<String>>(
        '/users/permissions',
        fromJson: (json) => (json as List).cast<String>(),
      ),
      errorContext: 'Failed to fetch permissions',
    );
  }

  /// Assign user to store
  Future<void> assignToStore(
    String userId,
    String storeId, {
    String? roleInStore,
    bool? canTransferTo,
    bool? canTransferFrom,
  }) async {
    await executeRequest<void>(
      () => apiClient.post(
        '/users/$userId/stores',
        data: {
          'store_id': storeId,
          if (roleInStore != null) 'role_in_store': roleInStore,
          if (canTransferTo != null) 'can_transfer_to': canTransferTo,
          if (canTransferFrom != null) 'can_transfer_from': canTransferFrom,
        },
      ),
      errorContext: 'Failed to assign user to store',
    );
  }

  /// Remove user from store
  Future<void> removeFromStore(String userId, String storeId) async {
    await executeRequest<void>(
      () => apiClient.delete('/users/$userId/stores/$storeId'),
      errorContext: 'Failed to remove user from store',
    );
  }
}
