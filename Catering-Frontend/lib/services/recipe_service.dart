import '../models/inventory_models.dart';
import 'api/base_api_service.dart';

class RecipeService extends BaseApiService {
  Future<PaginatedResult<RecipeItem>> getAll({
    ListQueryParams? queryParams,
  }) {
    return executePaginatedRequest<RecipeItem>(
      () => apiClient.get<Map<String, dynamic>>(
        '/recipes',
        queryParameters: queryParams?.toMap(),
      ),
      itemFromJson: RecipeItem.fromJson,
      errorContext: 'Failed to fetch recipes',
    );
  }

  Future<RecipeItem> create(Map<String, dynamic> data) {
    return executeRequest<RecipeItem>(
      () => apiClient.post<RecipeItem>(
        '/recipes',
        data: data,
        fromJson: (json) => RecipeItem.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      ),
      errorContext: 'Failed to create recipe',
    );
  }

  Future<RecipeItem> update(String id, Map<String, dynamic> data) {
    return executeRequest<RecipeItem>(
      () => apiClient.put<RecipeItem>(
        '/recipes/$id',
        data: data,
        fromJson: (json) => RecipeItem.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      ),
      errorContext: 'Failed to update recipe',
    );
  }
}