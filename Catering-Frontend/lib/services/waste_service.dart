import '../models/inventory_models.dart';
import 'api/api_exception.dart';
import 'api/base_api_service.dart';

class WasteService extends BaseApiService {
  static WasteService? _instance;

  static WasteService get instance {
    _instance ??= WasteService._internal();
    return _instance!;
  }

  WasteService._internal();

  Future<List<WasteRecord>> getAll() async {
    final response = await apiClient.get<List<WasteRecord>>(
      '/waste-records',
      fromJson: (json) {
        final records =
            json is List ? json : (json as Map)['items'] as List;
        return records
            .cast<Map<String, dynamic>>()
            .map(WasteRecord.fromJson)
            .toList();
      },
    );

    if (response.message == 'Waste Records feature not yet implemented') {
      throw const ApiException(
        message: 'Waste records are not implemented by the server yet.',
        statusCode: 501,
      );
    }
    if (response.isSuccess) return response.data!;
    throw ApiException(
      message: response.message ?? 'Failed to fetch waste records',
      errors: response.errors,
    );
  }

  Future<WasteRecord> create(Map<String, dynamic> data) async {
    return await executeRequest<WasteRecord>(
      () => apiClient.post<WasteRecord>(
        '/waste-records',
        data: data,
        fromJson: (json) => WasteRecord.fromJson(json as Map<String, dynamic>),
      ),
      errorContext: 'Failed to create waste record',
    );
  }

  Future<WasteRecord> update(String id, Map<String, dynamic> data) async {
    return await executeRequest<WasteRecord>(
      () => apiClient.put<WasteRecord>(
        '/waste-records/$id',
        data: data,
        fromJson: (json) => WasteRecord.fromJson(json as Map<String, dynamic>),
      ),
      errorContext: 'Failed to update waste record',
    );
  }
}