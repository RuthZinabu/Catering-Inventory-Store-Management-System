import '../screens/stock_transfers/stock_transfer_models.dart';
import 'api/api_exception.dart';
import 'api/base_api_service.dart';

class TransferService extends BaseApiService {
  static TransferService? _instance;
  static TransferService get instance => _instance ??= TransferService._();

  TransferService._();

  Future<List<StockTransferViewModel>> getAll() async {
    final result = await executePaginatedRequest<StockTransferViewModel>(
      () => apiClient.get<Map<String, dynamic>>('/transfers'),
      itemFromJson: StockTransferViewModel.fromJson,
      errorContext: 'Failed to load transfers',
    );
    return result.items;
  }

  Future<List<TransferStockItemViewModel>> getStock(String storeId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/stores/$storeId/stock',
      queryParameters: {'per_page': 100},
    );
    if (!response.isSuccess || response.data == null) {
      throw ApiException(message: response.message ?? 'Failed to load store stock');
    }
    final rows = response.data!['items'] as List? ?? const [];
    return rows
        .map((row) => TransferStockItemViewModel.fromJson(
            Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  Future<StockTransferViewModel> create(Map<String, dynamic> data) {
    return executeRequest<StockTransferViewModel>(
      () => apiClient.post<StockTransferViewModel>(
        '/transfers',
        data: data,
        fromJson: (json) => StockTransferViewModel.fromJson(
          Map<String, dynamic>.from(json as Map),
        ),
      ),
      errorContext: 'Failed to create transfer',
    );
  }

  Future<void> approve(String id) => _postAction(id, 'approve');
  Future<void> ship(String id) => _postAction(id, 'ship');
  Future<void> receive(String id, {String? notes}) => _postAction(id, 'receive', notes: notes);

  Future<void> cancel(String id) async {
    await executeRequest<void>(
      () => apiClient.delete('/transfers/$id'),
      errorContext: 'Failed to cancel transfer',
    );
  }

  Future<void> _postAction(String id, String action, {String? notes}) async {
    await executeRequest<Map<String, dynamic>>(
      () => apiClient.post<Map<String, dynamic>>(
        '/transfers/$id/$action',
        data: {if (notes != null) 'notes': notes},
      ),
      errorContext: 'Failed to $action transfer',
    );
  }
}