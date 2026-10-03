import '../screens/kitchen_issues/kitchen_issue_models.dart';
import 'api/api_exception.dart';
import 'api/base_api_service.dart';

class KitchenIssueService extends BaseApiService {
  static KitchenIssueService? _instance;
  static KitchenIssueService get instance => _instance ??= KitchenIssueService._();

  KitchenIssueService._();

  Future<List<KitchenIssueViewModel>> getAll() async {
    final result = await executePaginatedRequest<KitchenIssueViewModel>(
      () => apiClient.get<Map<String, dynamic>>('/kitchen-issues'),
      itemFromJson: KitchenIssueViewModel.fromJson,
      errorContext: 'Failed to load kitchen issues',
    );
    return result.items;
  }

  Future<List<KitchenIssueIngredientViewModel>> getStoreStock(String storeId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/stores/$storeId/stock',
      queryParameters: {'per_page': 100},
    );
    if (!response.isSuccess || response.data == null) {
      throw ApiException(message: response.message ?? 'Failed to load store stock');
    }
    final rows = response.data!['items'] as List? ?? const [];
    return rows.map((row) {
      final json = Map<String, dynamic>.from(row as Map);
      final item = Map<String, dynamic>.from(json['item'] as Map? ?? const {});
      return KitchenIssueIngredientViewModel(
        itemId: json['item_id'] as String? ?? '',
        name: item['name'] as String? ?? '',
        category: item['category'] as String? ?? '',
        unit: item['unit'] as String? ?? '',
        availableStock: _number(json['available_quantity']),
        quantity: 0,
      );
    }).toList();
  }

  Future<KitchenIssueViewModel> create(Map<String, dynamic> data) {
    return executeRequest<KitchenIssueViewModel>(
      () => apiClient.post<KitchenIssueViewModel>(
        '/kitchen-issues',
        data: data,
        fromJson: (json) => KitchenIssueViewModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      ),
      errorContext: 'Failed to submit kitchen issue',
    );
  }

  Future<void> approve(String id, {String? notes}) => _postAction(
        '/kitchen-issues/$id/approve',
        notes == null ? {} : {'approval_notes': notes},
      );

  Future<void> issue(String id) => _postAction('/kitchen-issues/$id/issue', {});

  Future<void> cancel(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/kitchen-issues/$id'),
      errorContext: 'Failed to cancel kitchen issue',
    );
  }

  Future<void> _postAction(String path, Map<String, dynamic> data) async {
    await executeRequest<Map<String, dynamic>>(
      () => apiClient.post<Map<String, dynamic>>(path, data: data),
      errorContext: 'Kitchen issue action failed',
    );
  }

  double _number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}