import 'package:flutter_test/flutter_test.dart';
import 'package:catering_inventory_store_management_system/services/api/api_response.dart';

void main() {
  test('successful empty response is accepted for void operations', () {
    final response = ApiResponse<void>.fromJson(
      {'success': true, 'message': 'Deleted successfully'},
      null,
    );

    expect(response.isSuccess, isTrue);
    expect(response.data, isNull);
  });
}